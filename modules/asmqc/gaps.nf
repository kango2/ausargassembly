process gaps {

    publishDir "${params.outdir}/${sample}/analysis/asmqc/${assembler}/gaps/${asmtype}", mode: 'copy', pattern : "*gaps.bed"

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*gaps.bed")

    script:
    
    """
    python3 /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/find_gaps.py -i ${asmfasta} -o \${PWD} -s ${sample}.${asmtype}.${assembler} -p ${task.cpus}
    
    """

    stub:

    """
    touch "${sample}.${asmtype}.${assembler}.test_gaps.bed"
    """
}

