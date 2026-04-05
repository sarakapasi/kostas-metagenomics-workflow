#!/bin/bash
#SBATCH -J nonpareil
#SBATCH -A INSERT-HERE #change to your own charge account
#SBATCH -n 8
#SBATCH --mem=100G
#SBATCH -t 12:00:00
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/log/031-nonpareil_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/log/031-nonpareil_err.16

source /storage/home/hcoda1/0/skapasi3/miniconda3/etc/profile.d/conda.sh

cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/1_rawdata/

conda activate nonpareil_env

# Files follow the format of NAME_R1_lcombined.fq.gz

for f in *R1_lcombined.fq.gz; do
    seqtk seq -a "$f" > "${f%.fq.gz}.fasta"
done

for input in *R1_lcombined.fasta; do
    base="${input%R1_lcombined.fasta}"
    nonpareil -s "$input" -T kmer -f fasta -b "$base" -X 50000 -t 8
done

rm *R1_lcombined.fasta

mv *.npo nonpareil_curve_files/
mv *.npa nonpareil_results/
mv *.npc nonpareil_results/
mv *.npl nonpareil_results/
