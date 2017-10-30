#!/bin/bash

# Adapted from: https://combine-lab.github.io/salmon/getting_started/
# paired-end example, read length = 100 so we use the "normal" index
salmon quant -i athaliana/ref/athaliana_normal_index -l A \
         -1 athaliana/data/DRR016125/DRR016125_1.fastq.gz \
         -2 athaliana/data/DRR016125/DRR016125_2.fastq.gz \
         -p 8 -o athaliana/quants/DRR016125_quant

# single-end example, read length = 36 so we use the "short" index
salmon quant -i athaliana/ref/athaliana_short_index -l A \
			-r athaliana/data/SRR074262/SRR074262.fastq.gz \
			-p 8 -o athaliana/quants/SRR074262_quant

# multi-sample experiment, read length = 50 so we use the "short" index
base=6080000;
for i in {7..9} {12..14};
do
	sam=$(($base + $i));
	samp="SRR"$sam;
	echo "Processing sample $samp";
	salmon quant -i athaliana/ref/athaliana_short_index -l A \
				-r athaliana/data/${samp}/${samp}.fastq.gz \
				-p 8 -o athaliana/quants/PRJNA408323/${samp}_quant;
done
