# ANSWERALS RNA Editing Pipeline (Nextflow)

A Nextflow implementation of the ANSWERALS paired DNA/RNA SNP detection workflow.

This pipeline modernizes the original bash-based SNPDetect workflow by migrating workflow orchestration to Nextflow and packaging software dependencies into an Apptainer container while preserving the validated SNPDetect analysis.

--------------------------------------------------------------------------------

OVERVIEW

The pipeline processes paired Whole Genome Sequencing (WGS) and RNA-seq BAM files to identify candidate RNA editing events using the existing SNPDetect workflow.

Rather than rewriting SNPDetect, the pipeline executes the validated software within a portable Apptainer container.

Pipeline execution:

Nextflow
    │
    ▼
Apptainer Container
    │
    ▼
snv_high_20_tn.sh
    │
    ▼
snv_generic.sh
    │
    ▼
Ace2.SAMStreamingSNPFinder

The container includes:

- Java 8
- samtools
- SNPDetect scripts
- SNPDetect Java libraries

Reference data (genome FASTA and dbSNP blob) remain external runtime inputs supplied when the workflow is launched.

--------------------------------------------------------------------------------

PROJECT STRUCTURE

nextflow_pipeline_parth/

├── main.nf
├── nextflow.config
├── run.sh
├── README.md
│
├── containers/
│   ├── Dockerfile
│   ├── conda.yml
│   ├── snpdetect/
│   └── snpdetect_java8_samtools_trimmed.sif
│
├── data/
│   └── WGS_RNAseq_sample_pairs.tsv
│
├── results/
├── reports/
├── logs_nf/
└── work/

--------------------------------------------------------------------------------

REQUIREMENTS

The pipeline is designed for execution on an IBM LSF cluster.

Required software:

- Nextflow
- IBM LSF
- Apptainer (or Singularity-compatible runtime)

Software bundled inside the container:

- Java 8
- samtools
- SNPDetect

Required runtime reference files:

- GRCh38.primary_assembly.genome.fa
- snp142_binary.blob

--------------------------------------------------------------------------------

INPUT SAMPLE SHEET

Input must be provided as a tab-separated values (TSV) file containing:

WGS_bam_file    RNA_bam_file    sample_name

Example:

/research/.../genome.bam
/research/.../rna.bam
NEUEN950VLE

Required columns:

- WGS_bam_file : Path to genomic BAM
- RNA_bam_file : Path to transcriptomic BAM
- sample_name  : Unique sample identifier

--------------------------------------------------------------------------------

CONFIGURATION

Pipeline configuration is stored in:

nextflow.config

Important parameters:

params.samplesheet
params.outdir
params.fna
params.blob
params.max_samples

Current execution profile:

executor = 'lsf'
queue = 'standard'

Process-specific CPU, memory, and runtime requests are configured using process labels.

--------------------------------------------------------------------------------

RUNNING THE PIPELINE

The recommended method is:

./run.sh

The launch script supplies:

- input sample sheet
- reference FASTA
- dbSNP blob
- execution reports
- resume support

Equivalent manual command:

nextflow \
    -log logs_nf/nextflow.log \
    run main.nf \
    -resume \
    --samplesheet <samplesheet.tsv> \
    --fna <reference.fa> \
    --blob <dbsnp.blob> \
    --max_samples 1 \
    -with-report reports/report.html \
    -with-timeline reports/timeline.html \
    -with-trace reports/trace.txt \
    -with-dag reports/flow.png

--------------------------------------------------------------------------------

TESTING

For development or validation runs, limit execution using:

--max_samples 1

Increase the value or remove the limit to process the complete sample sheet.

--------------------------------------------------------------------------------

OUTPUTS

Each processed sample generates its own output directory:

results/
└── SAMPLE_NAME/
    └── *.high_20.out

Nextflow working directories are stored in:

work/

Execution reports are written to:

reports/

Nextflow logs are written to:

logs_nf/

--------------------------------------------------------------------------------

CONTAINERIZATION

The workflow executes entirely inside an Apptainer container.

The container packages:

- Java 8
- samtools
- SNPDetect scripts
- SNPDetect Java libraries

External reference files (FASTA and dbSNP blob) are intentionally excluded from the container and supplied at runtime using workflow parameters. This keeps the container portable while allowing reference datasets to be updated independently of the software.

The container can be rebuilt from:

containers/
├── Dockerfile
├── conda.yml
└── snpdetect/

--------------------------------------------------------------------------------

USEFUL COMMANDS

Check running LSF jobs

bjobs

View completed job accounting

bacct -l <job_id>

Resume a failed pipeline

./run.sh

or

nextflow run main.nf -resume

View pipeline history

nextflow log

Inspect a failed process

cd work/<hash>/<hash>

cat .command.sh
cat .command.out
cat .command.err

Follow the latest task error log

tail -f $(ls -td work/*/* | head -1)/.command.err

Follow the latest task combined log

tail -f $(ls -td work/*/* | head -1)/.command.log

--------------------------------------------------------------------------------

REPORTS

The pipeline automatically generates:

report.html    - Execution summary

timeline.html  - Process execution timeline

trace.txt      - CPU, memory, and runtime statistics

flow.png       - Workflow DAG

--------------------------------------------------------------------------------

AUTHOR

Parth Patel
University of California, Los Angeles (UCLA)

--------------------------------------------------------------------------------

ACKNOWLEDGEMENTS

This project modernizes the execution of the validated SNPDetect workflow developed and maintained by Dr. Wu's bioinformatics infrastructure. The migration to Nextflow and containerization improves reproducibility, portability, scalability, and maintainability while preserving the underlying analytical methodology.