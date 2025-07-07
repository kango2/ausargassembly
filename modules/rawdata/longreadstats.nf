process longreadstats {

    input:
    tuple val (sample), val (tech), val (runid), val (fastq)

    output:
    tuple val (sample), val (tech), val (runid), path("*stats*.csv"), path("*freq*.csv")

    when:
    tech in ['ont', 'pb'] && fastq

    script:
    """
    module load pythonlib
    python3 long_read_qv.py -input ${fastq} -sample "${sample}.${tech}.${runid}" -output \${PWD}
    """

    stub: 

    """
    touch "${sample}.${tech}.${runid}.stats.csv"
    touch "${sample}.${tech}.${runid}.freq.csv"
    """
}
