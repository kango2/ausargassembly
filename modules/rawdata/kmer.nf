process kmer {

    input:
    tuple val (sample), val (tech), val (fastq)
    each mode

    output:
    tuple val (sample), val (tech), val (mode), path("${sample}.${tech}.${mode}.histo")

    when:
    tech in ['ont', 'pb', 'illumina'] && fastq

    script:

    def fastqjoined = fastq.join(';')

    """

    OUTDIR=\${PWD}
    export OUTDIR

    inputfiles=${fastqjoined}
    export inputfiles

    klength=${mode}
    export klength

    sampleID="${sample}.${tech}.${mode}"
    export sampleID
    
    bash kmercount.sh

    """

    stub: 

    """

    touch "${sample}.${tech}.${mode}.histo"

    """
}
