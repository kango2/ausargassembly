process longreadstats {

    publishDir "${params.rawdir}/${tech}/${runid}/fastx", pattern : "*.csv", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (fastq)

    output:
    tuple val (sample), val (tech), val (runid), path("*stats*.csv"), path("*freq*.csv")

    when:
    tech in ['ont', 'pb'] && fastq

    script:
    """
    module load pythonlib
    python3 /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/long_read_qv.py -input ${fastq} -sample "${sample}.${tech}.${runid}" -output \${PWD}
    """

    stub: 

    """
    touch "${sample}.${tech}.${runid}.stats.csv"
    touch "${sample}.${tech}.${runid}.freq.csv"
    """
}
