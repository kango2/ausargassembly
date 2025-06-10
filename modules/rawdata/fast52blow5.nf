process fast52blow5 {
    
    publishDir "${params.bpadata}/${sample}/${tech}/${runid}/raw", pattern : "*.blow5", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (chemistry), path (fast5)

    output:
    tuple val (sample), val (tech), val (runid), path("*.blow5")

    script:
    """
    # Convert fast5 files to blow5 format using slow5tools
    """

    stub:
    """
    touch "${sample}.${tech}.${runid}.blow5"
    """
}