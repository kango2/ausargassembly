process scaffoldhicmap {

    publishDir "${params.outdir}/${sample}/scaffolding/scaffoldhicmap", pattern : "*${sample}.${asmtype}.${assembler}*", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (asmtype), val (assembler), val (contigs), val (scaffolds), val (bin), val (agp)

    output:
    tuple val (sample), val (asmtype), val (assembler), path ("*.hic"), path ("*.assembly")


    script:

    """

    bin=${bin}
    agp=${agp}
    fasta=${contigs}
    output=\${PWD}
    sample=${sample}.${asmtype}.${assembler}
    
    export bin agp fasta output sample

    bash /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/yahstohicmap.sh
    
    """

    stub:

    """

    touch ${sample}.${asmtype}.${assembler}.hic
    touch ${sample}.${asmtype}.${assembler}.assembly
    
    
    """


}