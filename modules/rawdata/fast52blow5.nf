process fast52blow5 {
    
    publishDir "${params.bpadata}/${sample}/${tech}/${runid}/raw", pattern : "*.blow5", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (chemistry), val (passfast5tar), val (failfast5tar)

    output:
    tuple val (sample), val (tech), val (runid),  val (chemistry), path("*.blow5")

    script:
    """
    bash tar2slow5.sh -f ${failfast5tar} -p ${passfast5tar} -t \${PBS_JOBFS} -o \${PWD} -n "${sample}.${tech}.${runid}.blow5"
    """

    stub:
    """
    touch "${sample}.${tech}.${runid}.blow5"
    """
}