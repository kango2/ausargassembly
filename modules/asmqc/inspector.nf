process inspector {

    publishDir "${params.outdir}/inspector", mode: 'copy'

    input:
    tuple val (sample), val (tech), val (assembler), val (reads),  val (h1asm), val (h2asm)

    output:
    tuple val (sample), val (tech), val (assembler), path("*summary_statistics.txt"), path("*structural_error.bed"), path("*small_scale_error.bed")

    when:
    tech in ["pb"]

    script:
    
    """

    set -ex
    module use -a /g/data/if89/shpcroot/modules
    module load singularity quay.io/biocontainers/inspector/1.3.1--hdfd78af_1

    cat ${h1asm} ${h2asm} > \${PBS_JOBFS}/${sample}.${assembler}.diploid.fasta
    inspector -t ${task.cpus} -c \${PBS_JOBFS}/${sample}.${assembler}.diploid.fasta -r ${reads.join(' ')} -o ${sample}_${tech}_${assembler} --datatype hifi

    mv ${sample}_${tech}_${assembler}/summary_statistics ${sample}_${tech}_${assembler}.summary_statistics.txt
    mv ${sample}_${tech}_${assembler}/structural_error.bed ${sample}_${tech}_${assembler}.structural_error.bed
    mv ${sample}_${tech}_${assembler}/small_scale_error.bed ${sample}_${tech}_${assembler}.small_scale_error.bed

    
    """

    stub:

    """
    touch "${sample}_${tech}_${assembler}.summary_statistics.txt"
    touch "${sample}_${tech}_${assembler}.structural_error.bed"
    touch "${sample}_${tech}_${assembler}.small_scale_error.bed"
    """
}

