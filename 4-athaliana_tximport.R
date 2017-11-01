# J. Taroni 2017
# Aggregating transcript level quantification from Salmon to the gene-level
# with the tximport package. This procedure is performed at the experiment
# (rather than the single sample) level. Files are currently hardcoded.
# 
# See this guide:
# https://bioconductor.org/packages/devel/bioc/vignettes/tximport/inst/doc/tximport.html

# directory of the quants for the experiment
exp.directory <- file.path("athaliana", "quants", "PRJNA408323")

# individual sample directories
sample.directories <- list.files(exp.directory)

# list of quant files
sf.list <- lapply(sample.directories, 
                  function(x) list.files(file.path(exp.directory, x),
                                         pattern = "quant.sf",
                                         full.names = TRUE))

# get named vector of quant files
sf.files <- unlist(sf.list)
names(sf.files) <- gsub("_.*", "", sample.directories)

# we need the gene to transcript mapping -- this was generated as part of the
# the custom reference pipeline, as it is also input into 
# rsem-prepare-reference
gene2tx.file <- file.path("athaliana", "athaliana_np_gene2txmap.txt")
gene2tx.df <- readr::read_tsv(gene2tx.file, 
                              col_names = c("gene_id", "tx_name", "DROP"))
gene2tx.df <- dplyr::select(gene2tx.df, -DROP)

# reorder columns: transcript, gene
# this is the format required for tximport
tx2gene <- gene2tx.df[, c("tx_name", "gene_id")]

# get original transcript-level abundances & write to file
txi.out <- tximport::tximport(files = sf.files,
                              type = "salmon",
                              txOut = TRUE)
tx.df <- as.data.frame(txi.out$counts)
tx.df <- cbind(rownames(tx.df), tx.df)
colnames(tx.df)[1] <- "Transcript"
readr::write_tsv(tx.df, 
                 path = file.path(exp.directory,
                                  "PRJNA408323_tx_counts.tsv"))

# summarize to gene, we're specifically interested in length-scaled
# transcripts per million (lengthScaledTPM)
# "scaled using the average transcript length, 
# averaged over samples and to library size"
txi.sum <- tximport::summarizeToGene(txi = txi.out,
                                     tx2gene = tx2gene,
                                     countsFromAbundance = "lengthScaledTPM")

# as data.frame, write to file
lstpm.df <- as.data.frame(txi.sum$counts)
lstpm.df <- cbind(rownames(lstpm.df), lstpm.df)
colnames(lstpm.df)[1] <- "Gene"
readr::write_tsv(lstpm.df,
                 path = file.path(exp.directory,
                                  "PRJNA408323_gene_lengthScaledTPM.tsv"))
