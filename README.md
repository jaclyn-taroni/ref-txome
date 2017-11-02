## RNA-seq quantification with Salmon in the [Data Refinery](https://github.com/data-refinery/data_refinery) Context 

The ideas herein were formulated during a trip Kurt Wheeler (@kurtwheeler) and I took to the [COMBINE Lab](https://combine-lab.github.io/) (and the discussion that followed), with input from/discussion with Rob Patro (@rob-p) and Hirak Sarkar (@hiraksarkar), specifically.

-----

The _Arabidopsis thaliana_ example is a _rough sketch_ of what we might expect the RNA-seq component of transcriptomic data processing to look like in its most basic form. (Note that this has not undergone any code review process at present.)

#### Obtaining sequencing data 

Several _A. thaliana_ RNA-seq samples are downloaded from the [European Nucleotide Archive](https://www.ebi.ac.uk/ena) by running 
`0-athaliana_data_dl.sh` in the top directory. 

The examples include:

* A paired-end sample with a read length of 100bp -- [DRR016125](https://www.ebi.ac.uk/ena/data/view/DRR016125) 
* A single-end example with a read length of 36bp -- [SRR074262](https://www.ebi.ac.uk/ena/data/view/SRR074262)
* An single-end experiment, read length 50bp -- [PRJNA408323](https://www.ebi.ac.uk/ena/data/view/PRJNA408323) 

#### Creating a custom reference txome

An _A. thaliana_ custom reference can be obtained by running `1-athaliana_custom_ref.sh`in the top directory.

This runs [`scripts/get_custom_transcripts_fasta.sh`](https://github.com/jaclyn-taroni/ref-txome/blob/master/scripts/get_custom_transcripts_fasta.sh), which is the main script for preparing the custom reference. 
The GTF file is first filtered to remove any pseudogenes, as we expect these will negatively affect on our ability to quantify protein-coding transcripts (see also #1), and then passes this filtered GTF and the top level DNA FASTA file to [`rsem-prepare-reference`](https://github.com/deweylab/RSEM#i-preparing-reference-sequences) for building the custom reference. 
[`scripts/check_for_pseudogene_removal.R`](https://github.com/jaclyn-taroni/ref-txome/blob/update-readme/scripts/check_for_pseudogene_removal.R) is currently also run to determine if the GTF was correctly filtered and the custom reference contains all the expected transcripts.

The _A. thaliana_ genome information is pulled from [Ensembl Plants](http://plants.ensembl.org/Arabidopsis_thaliana/Info/Index). There are two other examples: _R. norvegicus_ (from [Ensembl](http://www.ensembl.org/index.html)) & _H. sapiens_ (from [GENCODE](http://www.gencodegenes.org/)), `rnorvegicus_custom_ref.sh` and `hsapiens_custom_ref.sh`, respectively.


#### Building a txome index

Two txome indices for use with [Salmon](https://github.com/COMBINE-lab/salmon) (specifically quasi-mapping-based mode) are built by running `2-athaliana_build_index.sh` in the top directory:

* A "short" index
	* For use with reads 50bp or less
	* `-k 23`
* A "normal" index
	* For use with all longer reads (the majority of what is publicly available)
	* `-k 31`

See the [Salmon documentation](http://salmon.readthedocs.io/en/latest/salmon.html#quasi-mapping-based-mode-including-lightweight-alignment) for more information about building an index for a transcriptome.

#### Quantification with Salmon

Quantification with Salmon for our three examples is performed with `3-athaliana_quant.sh`

_Note: The distribution of [read lengths in a fastq file](#checking-read-length-from-fastq-file) determines which txome index is appropriate for use with_`quant`.

#### Summarize to gene

`4-athaliana_tximport.R` summarizes the output of `salmon quant` to the gene-level. Specifically, we are interested in length-scaled transcripts per million (TPM). (See #6.)

-----

#### Checking read length from fastq file
An _A. thaliana_ example adapted from [Xiajun Dong](http://onetipperday.sterding.com/2012/05/simple-way-to-get-reads-length.html) and [Laurent Modolo](https://gist.github.com/l-modolo/7246864). (Note that this is not particularly _fast_.)
```sh
zcat athaliana/data/SRR6080007/SRR6080007.fastq.gz \
  | awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) \
    {print l, lengths[l]}}'
```
