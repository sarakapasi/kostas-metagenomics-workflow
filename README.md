# kostas-metagenomics-workflow
Standard workflow I use for metagenome analysis in Dr. Kostas Konstantinidis' lab at Georgia Tech
- Updates are in progress

## Typically, I follow the analysis path of:
1. Upload reads to PACE
2. Remove human reads with bmtagger (2.1 - run QC with Kraken2)
3. Trim reads with multitrim (3.1 - get coverage estimation with nonpareil, 3.2 - get beta diversity through mash distances)
4. Normalize trimmed reads with bbnorm
5. For both normalized and non-normalized reads: assembly with IDBA and metaspades
6. For both normalized and non-normalized reads, and both IDBA and metaspades results: bin contigs > 5000 bp with maxbin2 and metabat2 (6.1 - check quality with CheckM)
7. For both normalized and non-normalized reads, dereplicate bins per sample at 95% ANI with drep
8. Biologically dereplicate bins within samples at 95% and 99% ANI with drep

Files follow the format of (step)-tool.sbatch, for example, 021-kraken2.sbatch, 060-maxbin2.sbatch, 060-metabat2.sbatch, etc

For raw non-human reads, I do a couple of slightly different steps:
- Trim reads with fastp (1.1 - get coverage estimation with nonpareil, 1.2 - get beta diversity through mash distances)
- Assemble with just metaspades instead of IDBA and metaspades

To submit scripts, you can run, for example:
```
sbatch 031-nonpareil.sbatch
sbatch 032-mash.sbatch
```
You will need to create some conda environments for the workflow to work - I usually have it set out like:
```
conda create --name multitrim_env #with multitrim, bmtagger, and kraken2
conda activate multitrim_env
conda install kgerhardt::multitrim
conda install bioconda::bmtagger
conda install bioconda::kraken2
conda deactivate

conda create --name nonpareil_env #with nonpareil and mash
conda activate nonpareil_env
conda install bioconda::nonpareil
conda install bioconda::mash
conda deactivate

conda create --name spades_env #with metaspades and IDBA
conda activate
conda install bioconda::spades
conda install bioconda::idba
conda deactivate

conda create --name binning_env #with maxbin2 and metabat2
conda activate
conda install bioconda::maxbin2
conda install bioconda::metabat2
conda deactivate

conda create --name drep_env #with drep
conda activate
conda install bioconda::drep
conda deactivate
```
