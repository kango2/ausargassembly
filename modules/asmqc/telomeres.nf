process telomeres {

    publishDir "${params.outdir}/telomeres", mode: 'copy', pattern : "*${sample}.${asmtype}.${assembler}*"

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("${sample}.${asmtype}.${assembler}*telomeres.csv"), path ("${sample}.${asmtype}.${assembler}*chromsyntelo.tdt"), path ("${sample}.${asmtype}.${assembler}*telomeres.bed")

    script:
    
    """

    input="${asmfasta}"
    output="\${PWD}"
    permatch=80
    copies=100
    sample="${sample}.${asmtype}.${assembler}"
    export input output permatch copies sample

    bash /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/find_telomeres.sh
    python3 /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/chromsyntelomeres.py -csv "${sample}.${asmtype}.${assembler}_telomeres.csv" -fai "${asmfasta}.fai" -outtsv "${sample}.${asmtype}.${assembler}_chromsyntelo.tdt"
    python3 /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/telomere_to_bed.py -i "${sample}.${asmtype}.${assembler}_telomeres.csv" -o \${PWD}

    """

    stub:

    """

    touch "${sample}.${asmtype}.${assembler}.test_telomeres.csv"
    touch "${sample}.${asmtype}.${assembler}.test_chromsyntelo.tdt"
    touch "${sample}.${asmtype}.${assembler}.test_telomeres.bed"

    """
}

