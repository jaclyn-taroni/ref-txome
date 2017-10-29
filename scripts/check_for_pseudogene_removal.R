# J. Taroni 2017
# The purpose of this script is to check that pseudogenes (and only 
# pseudogenes), as determined by gene biotypes in the GTF file, have been 
# removed in the filtered GTF supplied to rsem-prepare-reference. 
# This also checks that the *.transcripts.fa file output of rsem-prepare-ref
# contains all the proper transcripts, i.e., only transcripts that
# pass said pseudogene filter.

args <- commandArgs(trailingOnly = TRUE)

gtf.file <- args[1]  # the original GTF file from Ensembl (or GENCODE)
filtered.gtf.file <- args[2]  # the GTF filtered to get rid of pseudogenes (AWK)
gene2tx.file <- args[3]  # the file mapping gene ids to tx ids 
tx.fasta.file <- args[4]  # the FASTA file output from rsem-prepare-reference

#### gtf filtering -------------------------------------------------------------

full.gtf <- rtracklayer::readGFF(gtf.file, version = 0)
np.gtf <- rtracklayer::readGFF(filtered.gtf.file, version = 0)

# were there any pseudogenes in there in the first place? if not, stop
np.check <- any(grepl("pseudogene", full.gtf$gene_biotype))

if (np.check) {
# if there were pseudogenes, were they removed in the filtered gtf?
  np.in.filt <- any(grepl("pseudogene", np.gtf$gene_biotype))
  if (np.in.filt) 
    stop("Pseudogenes were not removed from filtered gtf")
}

# get data.frame of gene id to transcript mapping
gene2tx.df <- np.gtf[, c("gene_id", "transcript_id")]

# get a list of ENSG genes, the elements will be all transcripts that map to
# each of these ids
gene.list <- split(x = gene2tx.df$transcript_id, f = gene2tx.df$gene_id)
gene.list <- lapply(gene.list, function(x) sort(unique(x)))  # now sort

#### gene to transcript mapping ------------------------------------------------

# read in "AWK-derived" gene to transcript mapping that was used with 
# rsem-prepare-reference
awk.gene2tx.df <- data.table::fread(gene2tx.file, 
                                    data.table = FALSE,
                                    header = FALSE)
awk.gene2tx.df <- awk.gene2tx.df[, 1:2]

# from the awk filtered gene to transcript mapping, make a gene list & sort
awk.gene.list <- split(x = awk.gene2tx.df[, 2], f = awk.gene2tx.df[, 1])
awk.gene.list <- lapply(awk.gene.list, function(x) sort(unique(x)))

# check if gene identifiers match
if (all.equal(names(gene.list), names(awk.gene.list))) {
  
  # do the unfiltered GTF database derived and "awk derived" gene to transcript
  # mapping match in every case?
  genetx.match <- 
    mapply(function(x, y) all.equal(x, y), x = gene.list, 
           y = awk.gene.list)
  
  # if not, throw error
  if (!is.logical(unlist(genetx.match))) {
    stop("Some gene 2 tx mappings differ between GTF
         and awk filtered gene mapping!")
  }
  
} else {  # if gene ids don't match, throw error
  stop("Different gene identifiers in GTF and filtered GTF gene lists!")
}

#### tx FASTA ------------------------------------------------------------------

# read in transcripts FASTA output from rsem-prepare-reference
ens.fa <- 
  seqinr::read.fasta(file = tx.fasta.file, 
                     seqtype = c("DNA"), as.string = FALSE, 
                     forceDNAtolower = TRUE,
                     set.attributes = TRUE, legacy.mode = TRUE, seqonly = FALSE, 
                     strip.desc = FALSE,
                     bfa = FALSE, sizeof.longlong = .Machine$sizeof.longlong,
                     endian = .Platform$endian, apply.mask = TRUE)

# right number of genes as compared to awk filtered gene to tx mapping?
num.of.tx.check <- length(ens.fa) == nrow(awk.gene2tx.df)

# are all the transcripts in the fasta in the GTF?
all.tx.in <- all(names(ens.fa) %in% gene2tx.df$transcript_id)

if (!(num.of.tx.check & all.tx.in)) {
  stop("Wrong number of tx in FASTA file or not all tx in GTF file")
} else {
  cat("\n\nEverything looks good!\n")
}
