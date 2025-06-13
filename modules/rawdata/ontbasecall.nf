process ontbasecall {
    
    publishDir "${params.bpadata}/${sample}/${tech}/${runid}/fastx", pattern : "*.fastq.gz", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (chemistry), val (blow5)

    output:
    tuple val (sample), val (tech), val (runid), path("*pass*fastq.gz")
    path("*fail*fastq.gz")

    script:
    """
    if [[ ${chemistry} == 'R9' ]]; then
        MODEL="dna_r9.4.1_450bps_sup.cfg"  
    elif [[ ${chemistry} == 'R10' ]]; then
        MODEL="dna_r10.4.1_e8.2_400bps_5khz_sup.cfg"  
    fi

    export MODEL

    OUTDIR=\${PWD}
    export OUTDIR

    OUTFILE="${sample}.${tech}.${runid}"
    export OUTFILE

    MERGED_SLOW5=${blow5}
    export MERGED_SLOW5
    
    bash basecall.sh
    """

    stub:
    """
    touch "${sample}.${tech}.${runid}.pass.fastq.gz"
    touch "${sample}.${tech}.${runid}.fail.fastq.gz"
    
    """
}