#!/usr/bin/env nextflow

nextflow.enable.dsl=2

if (!params.samplesheet)
    error "Missing required parameter: --samplesheet"

if (!params.fna)
    error "Missing required parameter: --fna"

if (!params.blob)
    error "Missing required parameter: --blob"

process SNPDetect {

    label 'snpdetect'

    input:
    tuple val(sample_name), val(wgs_bam), val(rna_bam)

    script:
    """
    mkdir -p ${params.outdir}/${sample_name}

    [[ ! -f "${wgs_bam}.bai" ]] && samtools index -@ ${task.cpus} "${wgs_bam}"
    [[ ! -f "${rna_bam}.bai" ]] && samtools index -@ ${task.cpus} "${rna_bam}"

    TNAME=\$(basename "${rna_bam}" | cut -f1 -d".")

    snv_high_20_tn.sh \\
        ${params.fna} \\
        ${params.blob} \\
        "${rna_bam}" \\
        "${wgs_bam}" \\
        "${params.outdir}/${sample_name}" \\
        "\${TNAME}.high_20.out" \\
        normal \\
        -allow-duplicates \\
        -min-unique-alt-read-start 1 \\
        -query-mode
    """
}

workflow {

    samples_ch = Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true, sep: '\t')
        .take(params.max_samples.toInteger())
        .map { row ->
            tuple(row.sample_name, row.WGS_bam_file, row.RNA_bam_file)
        }

    SNPDetect(samples_ch)
}