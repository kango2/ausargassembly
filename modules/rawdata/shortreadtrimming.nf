process shortreadtrimming {

    input:
    tuple val (sample), val (tech), val (runid), val (fastq)

    output:
    tuple val (sample), val (tech), val (runid), path ("*R1.trimmed*fastq.gz"), path ("*R2.trimmed*fastq.gz")

    when:
    tech == 'illumina' && fastq && fastq.contains(";")


    script:

    def (r1, r2) = fastq.split(';')*.trim()

    
    """
    
    singularity exec /g/data/if89/singularityimg/trimmomatic_latest.sif java -jar /Trimmomatic/dist/jar/trimmomatic-0.40-rc1.jar PE -threads 48 -phred33 -trimlog "${sample}.${runid}.trim.log" -summary "${sample}.${runid}.trim.summary" ${r1} ${r2} "${sample}.${runid}.R1.trimmed.fastq.gz" "${sample}.${runid}.R1.trimmed.unpaired.fastq.gz" "${sample}.${runid}.R2.trimmed.fastq.gz"  "${sample}.${runid}.R2.trimmed.unpaired.fastq.gz" ILLUMINACLIP:"/Trimmomatic/adapters/TruSeq3-PE.fa":2:30:10:2:True LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36 2>&1

    """

    stub: 

    """
    touch "${sample}.${runid}.R1.trimmed.fastq.gz"
    touch "${sample}.${runid}.R2.trimmed.fastq.gz"
    """


}