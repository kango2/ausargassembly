process busco {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*full_table.tsv"), path ("*short_summary.json")

    script:
    
    """
    
    """

    stub:

    """
    
    touch "${sample}_${tech}_${assembler}_${asmtype}.full_table.tsv"
    touch "${sample}_${tech}_${assembler}_${asmtype}.short_summary.json"

    """
}
