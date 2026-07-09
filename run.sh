#!/bin/bash
set -euo pipefail

mkdir -p logs_nf reports

module load Java/25.36
module load Nextflow/25.10.2

nextflow -log logs_nf/nextflow.log run main.nf \
  -profile stjude \
  -resume \
  --samplesheet data/WGS_RNAseq_sample_pairs.tsv \
  --fna /research/groups/cab/projects/Control/common/reference/snpdetect/GRCh38.primary_assembly.genome.fa \
  --blob /datasets/public/genomes/Homo_sapiens/GRCh38/SUPPORT/snp142_binary.blob \
  --max_samples 3 \
  -with-report reports/report.html \
  -with-timeline reports/timeline.html \
  -with-trace reports/trace.txt \
  -with-dag reports/flow.png