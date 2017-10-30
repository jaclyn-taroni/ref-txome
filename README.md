# ref-txome

#### Checking read length from fastq file
An _A. thaliana_ example adapted from [Xiajun Dong](http://onetipperday.sterding.com/2012/05/simple-way-to-get-reads-length.html) and [Laurent Modolo](https://gist.github.com/l-modolo/7246864). (Note that this is not particularly _fast_.)
```sh
zcat athaliana/data/SRR6080007/SRR6080007.fastq.gz \
  | awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) \
    {print l, lengths[l]}}'
```
