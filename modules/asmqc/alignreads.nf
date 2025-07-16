process alignreads {

    input:
    tuple val (sample), val (tech), val (asmtype), val (assembler), val (reads),  val (asmfasta)

    output:
    tuple val (sample), val (tech), val (asmtype),  val (assembler), path("*.bam")
    path ("*.bai")

    when:
    tech in ["illumina", "ont", "pb"]

    script:

    // add cases for when multiple files we cat 
    //otherwise assume single file 
    //reads is going to be a list. it will always have one file , or may have more
    // [file1] or incase of illumina [R1;R2]
    // if multiple files, reads is going to look like this [file1, file2] and illumina is going to look like [R1;R2, R1;R2]

    if (tech == "illumina") {
        // handle R1;R2:R1;R2 format
        def r1_files = []
        def r2_files = []
        reads.split(':').each { pair ->
            def (r1, r2) = pair.split(';')
            r1_files << r1
            r2_files << r2
        }
        def r1s = r1_files.join(" ")
        def r2s = r2_files.join(" ")

    """

    cat ${r1s} > ${sample}.${tech}.R1.merged.fastq.gz
    cat ${r2s} > ${sample}.${tech}.R2.merged.fastq.gz

    bwa-mem2 mem -t "${task.cpus}" -Y -K 100000000 ${asmfasta} ${sample}.${tech}.R1.merged.fastq.gz ${sample}.${tech}.R2.merged.fastq.gz | samtools sort - --reference ${asmfasta} -T \${PBS_JOBFS} -@ "${task.cpus}" --write-index --output-fmt BAM \
     -o "${sample}.${tech}.${assembler}.${asmtype}.bam"##idx##"${sample}.${tech}.${assembler}.${asmtype}.bam.bai"

    
    """

    }

    else if( tech == "ont" | tech == "pb" ) {
    
    readlist = reads.split(':').join(' ')
    preset = (tech == "ont") ? "map-ont" : "map-hifi"


    """

    cat ${readlist} > ${sample}.${tech}.merged.fastq.gz

    minimap2 -Y -K 2000M -t "${task.cpus}" -ax map-hifi ${asmfasta} ${sample}.${tech}.merged.fastq.gz | samtools sort - --reference ${asmfasta} -T \${PBS_JOBFS} -@ "${task.cpus}" --write-index --output-fmt BAM \
     -o "${sample}.${tech}.${assembler}.${asmtype}.bam"##idx##"${sample}.${tech}.${assembler}.${asmtype}.bam.bai"

    
    """

    }


    stub:

    """
    touch "${sample}_${tech}_${assembler}_${asmtype}.bam"
    touch "${sample}_${tech}_${assembler}_${asmtype}.bai"
    """
}

