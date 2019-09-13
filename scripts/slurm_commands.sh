# mapping reads to assembly and saving in BAM format

# Create coverage file
srun --nodes=1 --tasks-per-node=1 --cpus-per-task=16 --mem-per-cpu=2GB shifter --image=cimendes/minimap2:2.17-1 minimap2 -ax sr assembly.fa read1.fq read2.fq > aln.sam
srun --nodes=1 --tasks-per-node=1 --cpus-per-task=16 --mem-per-cpu=2GB shifter --image=biocontainers/samtools:v1.7.0_cv4 samtools sort -o sorted.bam -O bam -@ 6 align.sam
srun --nodes=1 --tasks-per-node=1 --cpus-per-task=16 --mem-per-cpu=2GB shifter --image=biocontainers/samtools:v1.7.0_cv4 samtools index align.sam

# BinSanity
srun --pty --nodes=1 --cpus-per-task=16 --mem-per-cpu=6 --tasks-per-node=1 shifter --image=cimendes/binsanity:0.2.8-1
simplify-fasta -i contigs.fasta  -o simple_contigs.fasta
get-ids -f $PWD -o contigs.ids  -l simple_contigs.fasta -x 1000 # limit contigs to 1000
Binsanity-profile -i simple_contigs.fasta -s ~/Binning_assessment/binning/mock/ --ids contigs.ids -c out.cov
Binsanity-wf -c out.cov.cov -f $PWD -o binning/ --threads 16 -l simple_contigs.fasta
Binsanity Binsanity -c out.cov.cov -f $PWD -l simple_contigs.fasta -o binning_composition/ --outPrefix BinSanity # sequence composition only

# CONCOCT
srun --pty --nodes=1 --cpus-per-task=16 --mem-per-cpu=6 --tasks-per-node=1 shifter --image=flowcraft/concoct:1.0.0-1
cut_up_fasta.py contigs.fasta -c 10000 -o 0 --merge_last -b contigs_10K.bed > contigs_10K.fa
concoct_coverage_table.py contigs_10K.bed ../sorted.bam > coverage_table.tsv
concoct --composition_file contigs_10K.fa --coverage_file coverage_table.tsv -b concoct_output/
merge_cutup_clustering.py concoct_output/clustering_gt1000.csv > concoct_output/clustering_merged.csv
mkdir concoct_output/fasta_bins
extract_fasta_bins.py original_contigs.fa concoct_output/clustering_merged.csv --output_path concoct_output/fasta_bins
