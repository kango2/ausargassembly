process contighicmap {

    publishDir "${params.outdir}/${sample}/scaffolding/contighicmap", pattern : "*${sample}.${asmtype}.${assembler}*", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val(tech) , val (assembler), val (asmtype),  val (reads), val (fasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (reads), val (fasta), path ("*.hic"), path ("*.assembly")

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
    fasta=${fasta}
    sample=${sample}.${asmtype}.${assembler}
    outdir=\${PWD}

    cat ${r1s.join(' ')} > "/iointensive/${sample}.${tech}.R1.merged.fastq.gz"
    cat ${r2s.join(' ')} > "/iointensive/${sample}.${tech}.R2.merged.fastq.gz"

    R1="/iointensive/${sample}.${tech}.R1.merged.fastq.gz"
    R2="/iointensive/${sample}.${tech}.R2.merged.fastq.gz"

    export fasta sample outdir R1 R2
    bash /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/juicer.sh
    """

    stub:

    """
    touch ${sample}.${asmtype}.${assembler}.test.hic
    touch ${sample}.${asmtype}.${assembler}.test.assembly
    """


}