#!/bin/sh

# create species directory
mkdir rnorvegicus && cd rnorvegicus

# download reference FASTA and GTF files
wget ftp://ftp.ensembl.org/pub/release-90/fasta/rattus_norvegicus/dna/Rattus_norvegicus.Rnor_6.0.dna.toplevel.fa.gz
wget ftp://ftp.ensembl.org/pub/release-90/gtf/rattus_norvegicus/Rattus_norvegicus.Rnor_6.0.90.gtf.gz
gunzip *.gz

# make reference directory
mkdir ref && cd ..

# create custom reference
sh scripts/get_custom_transcripts_fasta.sh \
	rnorvegicus/Rattus_norvegicus.Rnor_6.0.90.gtf \
	rnorvegicus/Rattus_norvegicus.Rnor_6.0.90.nonpseudogenes.gtf \
	rnorvegicus/nonpseudogenes.list \
	rnorvegicus/rnorvegicus_np_gene2txmap.txt \
	rnorvegicus/Rattus_norvegicus.Rnor_6.0.dna.toplevel.fa \
	rnorvegicus/ref/rnorvegicus_ensembl_Rnor_6.0

# check custom reference
Rscript scripts/check_for_pseudogene_removal.R \
	rnorvegicus/Rattus_norvegicus.Rnor_6.0.90.gtf \
	rnorvegicus/Rattus_norvegicus.Rnor_6.0.90.nonpseudogenes.gtf \
	rnorvegicus/rnorvegicus_np_gene2txmap.txt \
	rnorvegicus/ref/rnorvegicus_ensembl_Rnor_6.0.transcripts.fa
