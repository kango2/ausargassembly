
process hifiasm {

  publishDir "${params.outdir}", pattern : "*${sample}*", mode: 'copy', overwrite: true

  input:
  tuple val(sample), val(meta)

  output:
  tuple val(sample), val(meta), path("${sample}.p_ctg.fasta"), path("${sample}.hap1.p_ctg.fasta"), path("${sample}.hap2.p_ctg.fasta")
  tuple val(sample), val(meta), path("*.gfa")

  script:
    def pbArg  = meta.pb  ? "${meta.pb.join(' ')}"  : ""
    def ontArg = meta.ont ? "--ul ${meta.ont.join(',')}"    : ""
    
    def hicMergeCmds = ""
    def hicArgs = ""
    def asmprefix = "${sample}"

        if (meta.hic_r1 && meta.hic_r2 && meta.hic_r1.size() == meta.hic_r2.size()) {

            asmprefix = "${sample}.hic"
            def hicR1Merged = "${sample}.hic_r1.merged.fastq.gz"
            def hicR2Merged = "${sample}.hic_r2.merged.fastq.gz"

            if (meta.hic_r1.size() > 1) {

                def r1s = meta.hic_r1.join(' ')
                def r2s = meta.hic_r2.join(' ')

                hicMergeCmds = """
                echo "Merging Hi-C R1 for ${sample} (${meta.hic_r1.size()} files)"
                cat ${r1s} > ${hicR1Merged}
                echo "Merging Hi-C R2 for ${sample} (${meta.hic_r2.size()} files)"
                cat ${r2s} > ${hicR2Merged}
                """
                hicArgs = "--h1 ${hicR1Merged} --h2 ${hicR2Merged}"
            } else {
                hicArgs = "--h1 ${meta.hic_r1.join(' ')} --h2 ${meta.hic_r2.join(' ')}"
            }

        
        }

    """
    ${hicMergeCmds}
    hifiasm --telo-m CCCTAA -o ${sample} -t ${task.cpus} ${ontArg} ${hicArgs} ${pbArg}
    for hap in "" ".hap1" ".hap2"; do
        gfatools gfa2fa ${asmprefix}\${hap}.p_ctg.gfa > ${sample}\${hap}.p_ctg.fasta
    done
    """

  stub:
    def pbArg  = meta.pb  ? "${meta.pb.join(' ')}"  : ""
    def ontArg = meta.ont ? "--ul ${meta.ont.join(',')}"    : ""
    
    def hicMergeCmds = ""
    def hicArgs = ""
    def asmprefix = "${sample}"

        if (meta.hic_r1 && meta.hic_r2 && meta.hic_r1.size() == meta.hic_r2.size()) {

            asmprefix = "${sample}.hic"


            if (meta.hic_r1.size() > 2) {
                def hicR1Merged = "${sample}.hic_r1.merged.fastq.gz"
                def hicR2Merged = "${sample}.hic_r2.merged.fastq.gz"
                def r1s = meta.hic_r1.join(' ')
                def r2s = meta.hic_r2.join(' ')

                hicMergeCmds = """
                echo "Merging Hi-C R1 for ${sample} (${meta.hic_r1.size()} files)"
                cat ${r1s} > ${hicR1Merged} 
                echo "Merging Hi-C R2 for ${sample} (${meta.hic_r2.size()} files)"
                cat ${r2s} > ${hicR2Merged}
                """
                hicArgs = "--h1 ${hicR1Merged} --h2 ${hicR2Merged}"
            } else {
                hicArgs = "--h1 ${meta.hic_r1.join(' ')} --h2 ${meta.hic_r2.join(' ')}"
            }

        
        }

    """
    ${hicMergeCmds}
    echo hifiasm --telo-m CCCTAA -o ${sample} -t ${task.cpus} ${ontArg} ${hicArgs} ${pbArg}
    for hap in "" ".hap1" ".hap2"; do
        echo gfatools gfa2fa ${asmprefix}\${hap}.p_ctg.gfa 
    done

    touch ${sample}.p_ctg.fasta ${sample}.hap1.p_ctg.fasta ${sample}.hap2.p_ctg.fasta  
    touch ${sample}.p_ctg.gfa ${sample}.hap1.gfa ${sample}.hap2.gfa
    """
}


