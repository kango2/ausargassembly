process contigtoscaffold {

    publishDir "${params.outdir}/${sample}/scaffolding/yahs", pattern : "*${sample}.${asmtype}*", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (asmtype), val (assembler), val (fasta), val (hicmapping)

    output:
    tuple val (sample), val (asmtype), val ("yahs"), val (fasta), path ("${sample}.${asmtype}.yahs.fasta"), path ("${sample}.${asmtype}.yahs.bin"), path ("${sample}.${asmtype}.yahs.agp")
    path ("*${sample}.${asmtype}*")
    script:

    """
    module load seqkit singularity samtools
    yahsimg=/g/data/if89/singularityimg/yahs_1.2.2--h577a1d6_1.sif
    seqkit sort -lr ${fasta} > \${PBS_JOBFS}/\$(basename ${fasta} .fasta).sorted.fasta
    samtools faidx \${PBS_JOBFS}/\$(basename ${fasta} .fasta).sorted.fasta
    singularity exec \$yahsimg yahs --telo-motif CCCTAA -e GATC,GANTC,CTNAG,TTAA -r 10000,20000,50000,100000,200000,500000,1000000,1500000 -o \${PBS_JOBFS}/${sample}.${asmtype}.yahs \${PBS_JOBFS}/\$(basename ${fasta} .fasta).sorted.fasta ${hicmapping}
    mv \${PBS_JOBFS}/${sample}.${asmtype}.yahs_scaffolds_final.fa ${sample}.${asmtype}.yahs.fasta
    mv \${PBS_JOBFS}/${sample}.${asmtype}.yahs_scaffolds_final.agp ${sample}.${asmtype}.yahs.agp
    mv \${PBS_JOBFS}/${sample}.${asmtype}.yahs.bin ${sample}.${asmtype}.yahs.bin

    bwa index ${sample}.${asmtype}.yahs.fasta
    """

    stub:

    """
    touch ${sample}.${asmtype}.yahs.fasta
    touch ${sample}.${asmtype}.yahs.bin
    touch ${sample}.${asmtype}.yahs.agp
    """


}