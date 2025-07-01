process longreadstats {
    publishDir "${params.outdir}/rawdata/longreadstats", pattern : "*.csv", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (fastq)

    output:
    tuple val (sample), val (tech), val (runid), path("*stats*.csv"), path("*freq*.csv")

    script:
    """
    module load pythonlib
    python3 long_read_qv.py -input ${fastq} -sample "${sample}.${tech}.${runid}" -output \${PWD}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version 2>&1 | sed 's/Python //g')
        biopython: \$(python3 -c "import importlib.metadata; print(importlib.metadata.version('biopython'))")
    END_VERSIONS

    """

    stub: 

    """
    touch "${sample}.${tech}.${runid}.stats.csv"
    touch "${sample}.${tech}.${runid}.freq.csv"
    touch "versions.yaml"
    """
}
