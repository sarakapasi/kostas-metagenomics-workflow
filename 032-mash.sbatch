#!/bin/bash
#SBATCH -J mash
#SBATCH -A INSERT-HERE #change to your own charge account
#SBATCH -n 8
#SBATCH --mem=100G
#SBATCH -t24:00:00
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/log/032-mash_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/log/032-mash_err.16

source /storage/home/hcoda1/0/skapasi3/miniconda3/etc/profile.d/conda.sh

cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/1_rawdata/

conda activate nonpareil_env

for sample in $(ls *_R1_lcombined.fq.gz | sed 's/_R1_lcombined.fq.gz//'); do
    echo "Combining $sample..."

    cat ${sample}_R1_lcombined.fq.gz \
        ${sample}_R2_lcombined.fq.gz \
        > ${sample}_totalcombined.fastq.gz
done

mash sketch -p 8 -k 21 -s 10000 \
    -o mash_sketches/samples \
    rSw2-F*_S[0-9][0-9][0-9]_totalcombined.fastq.gz

# Samples followed naming convention rSw2-F**_S###_R1_lcombined.fq.gz and rSw2-F**_S###_R2_lcombined.fq.gz

mash dist mash_sketches/samples.msh mash_sketches/samples.msh \
    > mash_distances.tab


