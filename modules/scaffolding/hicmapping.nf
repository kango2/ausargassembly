process hicmapping {

    publishDir "${params.outdir}/${sample}/scaffolding/scaffoldtohicalign", pattern : "*${sample}.${asmtype}.${assembler}*", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech) ,val (assembler), val (asmtype),  val (reads), val (fasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (fasta), path ("*.bam")
    path ("*.bai")

    when:
    tech in ["hic"]

    script:

    def r1s = []
    def r2s = []

    for (pair in reads) {
        def (r1, r2) = pair.split(';')
        r1s << r1
        r2s << r2
    }

    """
    PBS_JOBFS=/iointensive 
    cat ${r1s.join(' ')} > "/iointensive/${sample}.${tech}.R1.merged.fastq.gz"
    cat ${r2s.join(' ')} > "/iointensive/${sample}.${tech}.R2.merged.fastq.gz"
    R1="/iointensive/${sample}.${tech}.R1.merged.fastq.gz"
    R2="/iointensive/${sample}.${tech}.R2.merged.fastq.gz"

    outputdir=\${PWD}
    fasta=${fasta}
    sample=${sample}.${asmtype}.${assembler}
    
    export fasta sample outputdir R1 R2
    bash /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/arima.sh
    
    """

    stub:

    """

    touch ${sample}.${asmtype}.${assembler}.hicmapping.bam
    touch ${sample}.${asmtype}.${assembler}.hicmapping.bam.bai
    
    
    """


}