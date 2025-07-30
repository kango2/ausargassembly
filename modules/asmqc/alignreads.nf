process alignreads {

    publishDir "${params.outdir}/${sample}/analysis/asmqc/${assembler}/alignreads/${tech}/${asmtype}", mode: 'copy', pattern : "*bam*"

    input:
    tuple val (sample), val (tech), val (assembler), val (asmtype), val (reads),  val (asmfasta)

    output:
    tuple val (sample), val (tech),val (assembler), val (asmtype),  path("*.bam")
    path ("*.bai")

    when:
    tech in ["illumina", "ont", "pb"]

    script:

    if (tech == "illumina") {
        def r1s = []
        def r2s = []

        for (pair in reads) {
            def (r1, r2) = pair.split(';')
            r1s << r1
            r2s << r2
        }

            if (r1s.size() == 1) {

                """

                bwa mem -t "${task.cpus}" -Y -K 100000000 ${asmfasta} ${r1s[0]} ${r2s[0]} | samtools sort - --reference ${asmfasta} -T \${PBS_JOBFS} -@ "${task.cpus}" --write-index --output-fmt BAM \
                -o "${sample}.${tech}.${assembler}.${asmtype}.bam"##idx##"${sample}.${tech}.${assembler}.${asmtype}.bam.bai"

                """
            } else {

            """

                cat ${r1s.join(' ')} > "/iointensive/${sample}.${tech}.R1.merged.fastq.gz"
                cat ${r2s.join(' ')} > "/iointensive/${sample}.${tech}.R2.merged.fastq.gz"

                bwa mem -t "${task.cpus}" -Y -K 100000000 ${asmfasta} "/iointensive/${sample}.${tech}.R1.merged.fastq.gz" "/iointensive/${sample}.${tech}.R2.merged.fastq.gz" | samtools sort - --reference ${asmfasta} -T \${PBS_JOBFS} -@ "${task.cpus}" --write-index --output-fmt BAM \
                -o "${sample}.${tech}.${assembler}.${asmtype}.bam"##idx##"${sample}.${tech}.${assembler}.${asmtype}.bam.bai"

            """


            }


    }

    else if( tech == "ont" | tech == "pb" ) {
    
    preset = (tech == "ont") ? "map-ont" : "map-hifi"

    if (reads.size() == 1) {

      """

        minimap2 -Y -K 2000M -t "${task.cpus}" -ax ${preset} ${asmfasta} ${reads[0]} | samtools sort - --reference ${asmfasta} -T \${PBS_JOBFS} -@ "${task.cpus}" --write-index --output-fmt BAM \
     -o "${sample}.${tech}.${assembler}.${asmtype}.bam"##idx##"${sample}.${tech}.${assembler}.${asmtype}.bam.bai"

     """

    }

    else {

    """

    cat ${reads.join(' ')} > "/iointensive/${sample}.${tech}.merged.fastq.gz"

    minimap2 -Y -K 2000M -t "${task.cpus}" -ax ${preset} ${asmfasta} "/iointensive/${sample}.${tech}.merged.fastq.gz" | samtools sort - --reference ${asmfasta} -T \${PBS_JOBFS} -@ "${task.cpus}" --write-index --output-fmt BAM \
     -o "${sample}.${tech}.${assembler}.${asmtype}.bam"##idx##"${sample}.${tech}.${assembler}.${asmtype}.bam.bai"

    
    """

    }

    }

    stub:

    """
    touch "${sample}_${tech}_${assembler}_${asmtype}.bam"
    touch "${sample}_${tech}_${assembler}_${asmtype}.bai"
    """
}

