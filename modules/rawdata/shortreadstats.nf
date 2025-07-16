process shortreadstats {

    publishDir "${params.rawdir}/${sample}/${tech}/${runid}/fastx", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (fastq)

    output:
    tuple val (sample), val (tech), val (runid), path("*.zip"), path("*.html")

    when:
    tech in ['illumina', 'hic'] && fastq && fastq.contains(";")

    script:

    def (r1, r2) = fastq.split(';')*.trim()
    
    """
    fastqc -o \${PWD} -t ${task.cpus} -f fastq ${r1} ${r2}
    """

    stub: 

    """

    touch "${sample}.zip"
    touch "${sample}.html"

    """
}