process srf {

    publishDir "${params.outdir}/${sample}/analysis/asmqc/${assembler}/srf/${asmtype}", mode: 'copy', pattern : "*${sample}.${asmtype}.${assembler}*"

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*asm2srf.abun"), path ("*asm2srf.bed"), path ("*asm2srf.paf"), path ("*srf.fa")

    script:
    
    """

    inputfasta="${asmfasta}"
    export inputfasta

    sampleid="${sample}.${asmtype}.${assembler}"
    export sampleid

    OUTPUTDIR="\${PWD}"
    export OUTPUTDIR
    
    klen=17
    export klen

    bash /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/runsrf.sh
    
    """

    stub:

    """
    touch "${sample}_${assembler}_${asmtype}.asm2srf.abun"
    touch "${sample}_${assembler}_${asmtype}.asm2srf.bed"
    touch "${sample}_${assembler}_${asmtype}.asm2srf.paf"
    touch "${sample}_${assembler}_${asmtype}.srf.fa"
    """
    
}

