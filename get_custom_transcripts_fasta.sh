#!/bin/sh

# with great input from Hirak Sarkar (@hiraksarkar)

GTF=$1
NONPSEUDOGTF=$2
NPLIST=$3
GENE2TXMAP=$4
FASTAPATH=$5
REFNAME=$6

# get list of non-pseudogenes from gtf
awk -F "\t" '$3 == "gene" { print $9 }' $GTF \
	| tr -d ";\"" \
	| awk '(index($0,"pseudogene") == 0){ print $2 }' > $NPLIST

# first, get the GTF header from the unfiltered GTF file
head -5 $GTF > $NONPSEUDOGTF

# grep everything in gtf that mentions pseudogenes
grep -Fwf $NPLIST $GTF >> $NONPSEUDOGTF

# get the gene to tx mapping for use with rsem-prepare-reference 
# the first column is gene ids 
# the second column is transcript ids (tximport will require reverse order)
awk -F "\t" '$3 == "transcript" { print $9 }' $NONPSEUDOGTF \
	| tr -d ";\"" \
	| awk '{ for (x=1;x<=NF;x++){ if ($x~"gene_id" || $x~"transcript_id") \
		printf "%s \t",$(x+1)}; printf "\n" }' \
	> $GENE2TXMAP

# prepare transcripts.fa with RSEM rsem-prepare-reference
rsem-prepare-reference --gtf $NONPSEUDOGTF \
	--transcript-to-gene-map $GENE2TXMAP \
	$FASTAPATH \
	$REFNAME
