#!/bin/bash
# use bwa mem to map map loci in fasta format against reference genome

# global variables (note: point to REFERENCE_GENOME)
readonly INPUT_FASTA="02_data/markers.fasta"
readonly REFERENCE_GENOME="02_data/genome/genome.fasta"
readonly INPUT_FOLDER="02_data"
readonly MAPPED_FOLDER="03_mapped"
readonly NUMPROCESSORS=16
readonly PROGNAME=$0

# Notes:
# Assumes adapters have been removed from reads
# Assumes reference is already indexed
# Otherwise, index it with:
#   bwa index /path/to/genome

# Extract informations for figures later
echo -e "Species\tLG\tTotalPosition" > ${INPUT_FASTA}.temp
grep ">" ${INPUT_FASTA} |
    perl -pe 's/>//; s/_/\t/g' |
    awk 'BEGIN {OFS="\t"} {print $1,$2,$4}' >> ${INPUT_FASTA}.temp

./01_scripts/utility_scripts/find_min_max_total_positions.py ${INPUT_FASTA}.temp ${INPUT_FASTA}.info

rm ${INPUT_FASTA}.temp

# Map reads using bwa mem 
# Align reads
echo "  Aligning reads to genome..."
bwa mem -t ${NUMPROCESSORS} ${REFERENCE_GENOME} ${INPUT_FASTA} > ${INPUT_FASTA}.sam 2> /dev/null

# keep only mapped reads (-F 4)
echo "  Filering non-mapped reads..."
samtools view -Sb -F 4 ${INPUT_FASTA}.sam > ${INPUT_FASTA}.mapped_only.bam 2> /dev/null

# Sort reads
echo "  Sorting bam file..."
samtools sort ${INPUT_FASTA}.mapped_only.bam ${INPUT_FASTA}.sorted 2> /dev/null

# clean temporary files
rm ${INPUT_FASTA}.mapped_only.bam
mv ./${INPUT_FOLDER}/*.sam ./${INPUT_FOLDER}/*.sorted.bam ./${MAPPED_FOLDER}/
