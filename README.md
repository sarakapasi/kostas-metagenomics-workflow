# kostas-metagenomics-workflow
Standard workflow I use for metagenome analysis in Dr. Kostas Konstantinidis' lab at Georgia Tech

Typically, I follow the analysis path of:
1. Upload reads to PACE
2. Remove human reads with bmtagger (2.1 - run QC with Kraken2)
3. Trim reads with multitrim (3.1 - get coverage estimation with nonpareil, 3.2 - get beta diversity through mash distances)
4. Normalize trimmed reads with bbnorm
5. For both normalized and non-normalized reads: assembly with IDBA and metaspades
6. For both normalized and non-normalized reads, and both IDBA and metaspades results: bin contigs > 5000 bp with maxbin2 and metabat2
7. For both normalized and non-normalized reads, dereplicate bins per sample at 95% ANI with drep
8. Biologically dereplicate bins within samples at 95% and 99% ANI with drep

Files follow the format of (step)-tool.sbatch, for example, 021-kraken2.sbatch, 06-maxbin2.sbatch, 06-metabat2.sbatch, etc
