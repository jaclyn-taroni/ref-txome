#!/bin/sh

# k = 31 is suitable for reads >=75bp
salmon index \
	-t athaliana/ref/athaliana_ensembl_TAIR10.transcripts.fa \
	-i athaliana/ref/athaliana_normal_index \
	--type quasi -k 31

# k = 23 is suitable for shorter reads
salmon index \
	-t athaliana/ref/athaliana_ensembl_TAIR10.transcripts.fa \
	-i athaliana/ref/athaliana_short_index \
	--type quasi -k 23
