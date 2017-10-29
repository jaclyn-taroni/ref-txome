#!/bin/sh

# create an arabidopsis data directory
cd athaliana && mkdir data && cd data

# download a paired-end sample, with long reads, an example from
# https://combine-lab.github.io/salmon/getting_started/#obtaining-reads
mkdir DRR016125 && cd DRR016125
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/DRR016/DRR016125/DRR016125_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/DRR016/DRR016125/DRR016125_2.fastq.gz
cd ..

# download a short, single-end example
mkdir SRR074262 && cd SRR074262
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR074/SRR074262/SRR074262.fastq.gz
