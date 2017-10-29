#!/bin/sh

# create species directory
mkdir hsapiens && cd hsapiens

# get gtf and fasta from GENCODE
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_24/gencode.v24.annotation.gtf.gz
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_24/GRCh38.primary_assembly.genome.fa.gz
gunzip *.gz

# make reference directory
mkdir ref && cd ..

# create custom reference
sh scripts/get_custom_transcripts_fasta.sh \
	hsapiens/gencode.v24.annotation.gtf \
	hsapiens/gencode.v24.annotation.nonpseudogenes.gtf \
	hsapiens/nonpseudogenes.list \
	hsapiens/hsapiens_np_gene2txmap.txt \
	hsapiens/GRCh38.primary_assembly.genome.fa \
	hsapiens/ref/hsapiens_release_24_GRCh38

# check pseudogene removal
Rscript scripts/check_for_pseudogene_removal.R \
	hsapiens/gencode.v24.annotation.gtf \
	hsapiens/gencode.v24.annotation.nonpseudogenes.gtf \
	hsapiens/hsapiens_np_gene2txmap.txt \
	hsapiens/ref/hsapiens_release_24_GRCh38.transcripts.fa
