#  Benchmarking of taxonomic independent metagenomic binning software for short-read data

This is an atempt to benchmark with relevant metagenomic binning software that does not rely on a reference database.

:warning: WORK IN PROGRESS :warning:


## Table of Contents

* [Introduction](#introduction)
* [Methods](#methods)
    * [Metagenomic Dataset](#metagenomic-datasets)
        * [simulated dataset](#simulated-dataset)
        * [Zymos community standard](#zymos-community-standard)
        * [Real dataset](#real-dataset)
    * [Binning tools and commands](#binning-tools-and-commands)
    * [Assessing Binning Success](#assessing-binning-success)
* [Results](#resuls)
* [References](#references)
* [Authors](#authors)


## Introduction
Shotgun metagenomics can offer relatively unbiased pathogen detection and characterization, potentially able to provide 
genotyping, antimicrobial resistance and virulence profiling in a single methodological step. This comes with the cost 
of producing massive amounts of information that require expert handling and processing, as well as capable 
computational infrastructures. One of the biggest challenges when dealing with metagenomic data is the lack of gold 
standards, although major efforts are being made on the standardization and assessment of software, both commercial and 
open source (Angers-Loustau et al., 2018; Gruening et al., 2018; Sczyrba et al., 2017: Couto et al., 2018). 

A plethora of tools are available specifically for metagenomic data, both short and long read data, and several 
combinations of these tools can be used to characterize the causative agent in a patient's infection in a fraction of 
the time required by traditional methods. The basic strategy for analysing metagenomic data is either a direct 
classification and characterization of the sequencing data, a metagenomic assembly followed by taxonomic independent 
or dependent binning that is then classified and characterized, or a combination of both. The assembly methods provide 
longer sequences are more informative than shorter sequencing data and can provide a more complete picture of the 
microbial community in a given sample. 

In metagenomics, the grouping of the different contigs obtained in the metagenomic assembly, ideally each collecting 
the sequences that belong to a microorganism present in the sample, represent the greatest bottleneck when trying to 
obtain fiable, reproducible results. The euristics implemented in this process, necessary due to the complexity of the 
task, make the assessment of precision and recall necessary. The binning process can be **taxonomy dependent**, relying 
on a database to aggregate the sequences, or **independent**. The first approach has many of the issues shared with the 
direct analysis of metagenomic read data as it’s highly dependent on the database use. 

The independent approach has the benefit of not relying on a database, instead using the composition of each sequence 
and coverage profiles to cluster together sequences that might belong to the same organism. These algorithms don’t 
require prior knowledge about the genomes in a given sample, relying instead on features inherent to the sequences in 
the sample. Although most binning softwares can work with single metagenomic samples, most make use of differential 
coverage of multiple samples to improve the binning process (Sedlar et al., 2016). This relies on the underlying 
principle that different organisms will be present in different proportions, therefore having a different coverage 
profile in the sample, which is not always true. Enrichment steps prior to sequencing, such as probes, can 
significantly alter the abundance profile making it more homogeneous, which might have profound consequences in the 
binning performance. The sampling as sequencing also introduce biases in the relative abundance of the organisms 
represented, either masking low abundance ones or over-representing certain taxas. 

The binning process represents a huge constraint in the analysis of metagenomic data. It’s an essential step to be able 
to retrieve information with a taxonomic context but thresholds need to be met on the purity and completeness of the 
bins obtained. Taxonomic independent are usually preferred as the results obtained aren’t constrained by the database 
used, but regardless of the methodology used, the results obtained are often unreliable and unreproducible due to the 
low recall of these methods (Sczyrba et al., 2017). The latest binning comparison happened in 2017, with the first CAMI 
challenge using simulated data sets, generated from ∼700 newly sequenced microorganisms and ∼600 novel viruses and 
plasmids and representing common experimental setups, where maxbin2 was considered superior (Sczyrba et al, 2017). To 
the best of our knowledge, no assessment of the influence of complexity of the communities nor the variability of 
proportion within the communities was performed. 


## Methods

#### Simulated dataset
With the [M3S3 tool](http://medweb.bgu.ac.il/m3s3/), a simulation sample was obtained made up of the Zymobiomics 
microbial community standasrd species of bacteria and yeast. The sample has the following composition (obtained with 
Kraken2 with the minimkaken2_V1 database):

#### Zymos community Standard
Two commercially available mock communities containing 10 microbial species (ZymoBIOMICS Microbial Community Standards) 
were sequences by [Nicholls et al. 2019](https://academic.oup.com/gigascience/article/8/5/giz043/5486468). Shotgun 
sequencing of the Even and Log communities was performed with the same protocol, with the exception that the Log 
community was sequenced individually on 2 flowcell lanes and the Even community was instead sequenced on an Illumina 
MiSeq using 2×151 bp (paired-end) sequencing. They are available under accession numbers 
[ERR2984773](https://www.ebi.ac.uk/ena/data/view/ERR2984773) (even) and 
[ERR2935805](https://www.ebi.ac.uk/ena/data/view/ERR2935805) (log). 

#### Real dataset
As a real metagenomic dataset, the three CAMI synthetic metagenome challenge sets was used (Low (L), Medium with 
differential abundance (M), and High complexity with time series (H)). These datasets are publicly available in 
[GigaDB](http://gigadb.org/dataset/100344). 

### Assembly and Contig BAM generation
TODO - SPAdes and minimap2? or Bowtie2? 

### Binning tools and Commands

#### BinSanity
Unsupervised clustering of environmental microbial assemblies using coverage and affinity propagation. Published by 
[Graham et al., 2017](https://peerj.com/articles/3035/). BinSanity is a **abundance based/hybrid** methods that takes 
as input a metagenomic assembly, in FASTA format, and a BAM file of the metagenomic reads mapped to the assembly. The 
sequence composition model is computd by utilizing the percentage of GC and tetranucleotide frequencies, and the 
differential abundace model takes the mapping results and log transforms the coverage matrix computed from those. The 
initial set of clusters is determined by coverage, feeding into the affinity propagation (AP) clustering algorythm, 
using the minimum euclidean distance as a stopping criteria. The %GC and tetranucleotide frequency matrix can be 
used **optionally** in a second refinement step to recluster contigs from high contamination and low complexion bins. 

* Source code: https://github.com/edgraham/BinSanity (last update: 20 Jun 2019)
* Container image: `cimendes/binsanity:0.2.8-1`

#### CONCOCT
CONCOCT is a program that uses Gaussian mixture models to cluster contigs into genomes based on sequence composition 
and coverage across multiple samples, although it can accept as input only one. Publised by 
[Alneberg et al. 2014](https://www.nature.com/articles/nmeth.3103), this ** hybrid binner* takes as input the 
(co)assembled metagenome and raw reads or abundace profile files. The sequence composition model is created by k-mer 
frequencies of the provided assembly (tetranucleotide by default), tranformed by uniform Dirichlet distribution prior 
on the relative frequencies dimension reduction using principal component analysis to keep 90% of joined composition 
and coverage variance. The abundance model is computed by combined log-transformed profile of normalized coverage and 
composition vectors. The sequences are clustered by Gaussian mixture models with regularized exprectation-maximization. 
The initial cluster number is determined by automatic relevance determination. The iteration stopping point is 
determined by prameter convergence and mazimization iteration number. Additionally, empirical variational Bayesian 
approach is also implemented. Variational approximation used to perform integral in optimizing mixing coefficients. 

* Source code: https://github.com/BinPro/CONCOCT (last update: 25/02/2019)
* Container image: `flowcraft/concoct:1.0.0-1`

#### MaxBin2
The second iteration of the MaxBin tool, published a two years later by 
[Wu et al., 2016](https://academic.oup.com/bioinformatics/article/32/4/605/1744462), allowing for co-assembled genomes. 
It's an **hybrid** assembler, taking as input contgs and raw reads or and abundance profile. Tetranucleotide frequencies are extracted 
from the sequences, and Euclidean distance, empirically estimated Gaussian distributions of intra- and inter-genome 
distances are calculated. The coverage model is computed through a Poisson distribution. An Expectation-maximization 
algorithm is used to cluster the sequences, with an initial cluster number estimated from 107 single-copy genes 
(Dupont et al 2012)(alternatively 40 bacteria and archea single copy gene database can be used). Initial parameters 
inferred from the shortest marker gene. The stopping criteria is parameter convergence and maximum iteration number (50 
by default). The bins are recursively checked for median number of marker genes and completness and contamination is 
reported based on these markers. 

* Source code: https://sourceforge.net/projects/maxbin2/ (last update: 22/06/2019)
* Container image: `flowcraft/maxbin2:2.2.4-1`

#### MetaBAT2
Published by [Kang et al., 2019](https://peerj.com/articles/7359/), it's the second iteration of the MetaBAT tool as 
an effort to overcome MetaBAT's limitation of having to set the initial parameters. MetaBAT2 is an **hybrid** binner 
that integrates empitical probabilistic distances of genome abundance and tetranucleotide frequency for accurate 
metagenome binning. Sequence composition is computed by rank-normalized tetranucleotide frequencies, Euclidean 
distance and empirical posterior probability derived from different contig sizes using logistic regression. 
It also computes an abundance correlation score (for 3 samples or more). Abundance distance defined as the non-shared 
area of two normal distributions. It implements graph-based structure for contig clustering. with an iterative procedure 
of graph building and graph partitioning using a modified laber propagation algorithm. The stopping criteria is 
graph maximization. Additionally, there's a progressive wighting of the relative importance of Distance Abundance vs 
Tetranucleotide frequency based on the number of samples. There's an optional assembly, based on checkM assessment, 
of mapped reads from the single most represented sample to reduce contamination. 

* Source code: https://bitbucket.org/berkeleylab/metabat (last update: 12/06/2019)
* Container image: `cimendes/metabat2:2.13-33-g236d20e-1`

#### MetaProb
Metagenomic reads binning based on probabilistic sequence signatures. This binner, unlike the majority of the tools 
available, utilizes the reads directly. It was published by [Girotto et al., 2016](https://academic.oup.com/bioinformatics/article/32/17/i567/2450796).
This *composition based* binner progressively merges reads together based on the extent of their overlap (shared q-mers). 
Each group is represented by a set of independent reads on which the k-mer frequency distribution is computed. 
Clustering of groups is based on their signature with the k-means algorithm., with the number of clusters estimated by 
Kolmogorov-Smirnov test. Each time a cluster passes the Kolmogorov-Smirnov test, the corresponding reads are removed and 
the other clusters are split. The test is repeated until no data is left. 

* Source code: https://bitbucket.org/samu661/metaprob/src (last update: 03/12/2018)
* Container image: `cimendes/metaprob:2-1`

#### MyCC
Published by [Lin & Liao, 2016](https://www.nature.com/articles/srep24175), this **composition bases** binner extracts genomic signatures by calculating the count of occurrences 
for every kmer (default tetranucleotides) followed by normalization ang centered log-ratio tranformation. Dimension 
reduction of the frequencies by Barnes-Hut-SNE. The matrix is then clustered by affinity propagation, stopping when 
minimum euclidean distance between pairs of datapoints is reached. Bin refinement step implemented with 40 universal 
prokaryotic phylogenetic marker genes (Ciccareli et al, 2006). 

* Source code: https://sourceforge.net/projects/sb2nhri/files/MyCC/ (last update: 15/03/2017)
* Container image: `990210oliver/mycc.docker:v1`

#### VAMB
VAMB, Variational Autoencoder for Metagenomic Binning, is an **hybrid** binner published as pre-print by 
[Nissen et al., 2018](https://www.biorxiv.org/content/10.1101/490078v2). It takes as input the assembled contigs and 
the BAM files of the reads mapped to the assembly. Sequence composition is encoded as a matrix of tetranucleotide 
frequencies, and abundance given in reads per kilobase contig per million mapped reads (RPKM). 
The variational autoencoder (VE) is trained for 500 epochs with TNF and abundance table as input. VE has two hidden 
layers, encoding the the data as a multivariate Gaussian latent distribution. DNA sequences and co-abundance are 
encoded to the mean of their latent distribution. This distribution is randomly sampled to estimate a threshold for 
the clustering based on pearson distance between contigs. Meedoid  covergence (iterative medoid clustering) is used to 
construct final bins. 

* Source code: https://github.com/RasmussenLab/vamb (last update: 13/09/2019)
* Container image: `cimendes/vamb:2.0.1-1`

#### YAMB
YAMB implementes metagenome binning using nonlinear dimensionality reduction and density-based clustering, and was 
published as a preprint by [Korzhenkov, 2019](https://www.biorxiv.org/content/10.1101/521286v1). It requires as input 
the sequencing reads and a metagenomic assembly. The sequence data is encoded as tetranucleotide frequencies for each 
contig fragment (10000 bp default). Mean coverage of fragments is calculated by samtools, then a matrix is created where 
rows correspond to contig fragments and columns to tetranucleotide occurences and fragment mean coverage. This matrix is 
dimensionality scaled using t-SNE (t-distributed stochastic neighbour embeding) performed on normalized data. 
Subsequent clustering with HDBSCAN to obtain the bins. 

* Source code: https://github.com/laxeye/YAMB (last update: 14/03/2019)
* Container image: `cimendes/yamb:1-1`

### Assessing Binning success

## Results

## References

* Angers-Loustau, A., Petrillo, M., Bengtsson-Palme, J., Berendonk, T., Blais, B., Chan, K.-G., et al. (2018). The challenges of designing a benchmark strategy for bioinformatics pipelines in the identification of antimicrobial resistance determinants using next generation sequencing technologies. F1000Research 7, 459. doi:10.12688/f1000research.14509.1.
* Couto, N. et al. Critical steps in clinical shotgun metagenomics for the concomitant detection and typing of microbial pathogens. Sci. Rep. 8, 13767 (2018).
* Gruening, B., Sallou, O., Moreno, P., Leprevost, F. D. V., Ménager, H., Søndergaard, D., et al. (2018). Recommendations for the packaging and containerizing of bioinformatics software. F1000Research 7, 742. doi:10.12688/f1000research.15140.1.
* Sczyrba, A., Hofmann, P., Belmann, P., Koslicki, D., Janssen, S., Dröge, J., et al. (2017). Critical Assessment of Metagenome Interpretation—a benchmark of metagenomics software. Nature Methods 14, 1063–1071. doi:10.1038/nmeth.4458.
* Sedlar, K., Kupkova, K., and Provaznik, I. (2017). Bioinformatics strategies for taxonomy independent binning and visualization of sequences in shotgun metagenomics. Computational and Structural Biotechnology Journal 15, 48–55. doi:10.1016/j.csbj.2016.11.005.


## Authors

* Inês Mendes 
    * Instituto de Microbiologia, Instituto de Medicina Molecular, Faculdade de Medicina, Universidade de Lisboa, 
    Lisboa, Portugal; 
    * University of Groningen, University Medical Center Groningen, Department of Medical Microbiology and Infection 
    Prevention, Groningen, The Netherlands
