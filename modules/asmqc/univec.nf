process univec {

    publishDir "${params.outdir}/univec", mode: 'copy', pattern : "*univec.txt"

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*univec.txt")

    script:
    
    """
    
    module load blast/2.14.1
    db=/g/data/if89/datalib/UniVecDB/UniVecDB
    database="\$db"

    blastn -reward 1 -penalty -5 -gapopen 3 -gapextend 3 -dust yes -soft_masking true -evalue 700 -searchsp 1750000000000 -query "${asmfasta}" -db "\$db" \
     -out "${sample}.${asmtype}.${assembler}.univec.txt" -num_threads "${task.cpus}" -outfmt 6

    """

    stub:

    """
    touch "${sample}_${assembler}_${asmtype}.univec.txt"
    """
}

