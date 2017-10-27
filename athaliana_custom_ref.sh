#!/bin/sh

# species directory 
mkdir athaliana && cd athaliana

# download reference FASTA and GTF files
wget ftp://ftp.ensemblgenomes.org/pub/release-37/plants/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
wget ftp://ftp.ensemblgenomes.org/pub/release-37/plants/gtf/arabidopsis_thaliana/Arabidopsis_thaliana.TAIR10.37.gtf.gz
gunzip *.gz

# make ref directory
mkdir ref && cd ..

# get custom reference
sh get_custom_transcripts_fasta.sh \
	athaliana/Arabidopsis_thaliana.TAIR10.37.gtf \
	athaliana/Arabidopsis_thaliana.TAIR10.37.nonpseudogenes.gtf \
	athaliana/nonpseudogenes.list \
	athaliana/athaliana_np_gene2txmap.txt \
	athaliana/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
	athaliana/ref/athaliana_ensembl_TAIR10
