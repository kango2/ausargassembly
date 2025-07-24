process merqury {

    publishDir "${params.outdir}/${sample}/analysis/asmqc/${assembler}/merqury/${tech}/${kmer}", mode: 'copy', pattern : "*merqury*"

    input:
    tuple val (sample), val (tech), val (assembler), val (reads), val (h1), val (h2)
    each (kmer)

    output:
    tuple val (sample), val (assembler), val (h1), val (h2), path ("*merqury*")

    when:
    tech in ["illumina"]

    script:
    
    """

    for pair in ${reads.collect { "\"${it}\"" }.join(" ")}; do
        IFS=';' read -r r1 r2 <<< "\$pair"
        cat \$r1 >> \${PBS_JOBFS}/${sample}.${tech}.R1.fastq.gz
        cat \$r2 >> \${PBS_JOBFS}/${sample}.${tech}.R2.fastq.gz
    done

    meryl count threads=30 k=${kmer} \${PBS_JOBFS}/${sample}.${tech}.R1.fastq.gz \${PBS_JOBFS}/${sample}.${tech}.R2.fastq.gz output "${sample}_${kmer}.meryl"
    \${MERQURY}/merqury.sh "${sample}_${kmer}.meryl" "${h1}" "${h2}" "${sample}.${kmer}.merqury"

    
    """

    stub:

    """
    touch "${sample}.${tech}.${assembler}.merqury.bed"
    """
}

