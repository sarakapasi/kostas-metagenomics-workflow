#!/bin/bash
#SBATCH -J bmtagger
#SBATCH -A INSERT-HERE #change to your own charge account
#SBATCH -N1 --ntasks-per-node=20
#SBATCH -t 7:00:00
#SBATCH -q inferno
#SBATCH --mem=180G 
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/log/020-bmtagger_out.16 #change to your preferred log path
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/log/020-bmtagger_err.16 #change to your preferred log path

source /storage/home/hcoda1/0/skapasi3/miniconda3/etc/profile.d/conda.sh
conda activate multitrim_env

cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/0_databases/ #change to file directory of your databases

#Download human genome for use in bmtagger
wget https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.fna.gz
gunzip GRCh38_latest_genomic.fna.gz

srprism mkindex -i GRCh38_latest_genomic.fna -o GRCh38_latest_genomic.srprism
bmtool -d GRCh38_latest_genomic.fna -o GRCh38_latest_genomic.bitmask -A 0 -w 18

cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/1_rawdata/ #change to file directory of your raw data
mkdir -p cleaned_reads

BITMASK="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/0_databases/GRCh38_latest_genomic.bitmask" #change to the database path
SRPRISM="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/0_databases/GRCh38_latest_genomic.srprism" #change to the database path

process_sample() {
    R1=$1
    SAMPLE=$(basename "$R1" _R1_001.fastq.gz)
    R2="${SAMPLE}_R2_001.fastq.gz"
    
    if [ ! -f "$R2" ]; then
        echo "Warning: $R2 not found for $SAMPLE, skipping..."
        return
    fi
    echo "Processing sample: $SAMPLE"
 
    gunzip -c "$R1" > "temp_${SAMPLE}_R1.fastq"
    gunzip -c "$R2" > "temp_${SAMPLE}_R2.fastq"
    
    bmtagger.sh \
      -b "$BITMASK" \
      -x "$SRPRISM" \
      -q 1 \
      -1 "temp_${SAMPLE}_R1.fastq" \
      -2 "temp_${SAMPLE}_R2.fastq" \
      -o "${SAMPLE}_bmtagger"
    
    extract_fullseq "${SAMPLE}_bmtagger.list" "temp_${SAMPLE}_R1.fastq" | gzip > "cleaned_reads/${SAMPLE}_R1_001.fastq.gz"
    extract_fullseq "${SAMPLE}_bmtagger.list" "temp_${SAMPLE}_R2.fastq" | gzip > "cleaned_reads/${SAMPLE}_R2_001.fastq.gz"
    rm "temp_${SAMPLE}_R1.fastq" "temp_${SAMPLE}_R2.fastq" "${SAMPLE}_bmtagger.list"
    echo "Completed $SAMPLE"
}

export -f process_sample
export BITMASK SRPRISM
# Run in parallel
ls *_R1_001.fastq.gz | xargs -P "$THREADS" -I {} bash -c 'process_sample "$@"' _ {}

echo "All samples processed"
