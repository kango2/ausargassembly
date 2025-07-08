process hifiasm {

  publishDir "${params.analysisdir}/${sample}/hifiasm", pattern : "*${sample}*", mode: 'copy', overwrite: true

  input:
  tuple val(sample), val(meta)

  output:
  tuple val(sample), val(meta), path("${sample}.p_ctg.fasta"), path("${sample}.hap1.p_ctg.fasta"), path("${sample}.hap2.p_ctg.fasta")
  tuple val(sample), val(meta), path("*.gfa")

  script:
    // Flatten PB files
    def pbFiles = meta.pb*.file
    def pbArg = pbFiles ? pbFiles.join(' ') : ""

    // Flatten ONT files
    def ontFiles = meta.ont*.file
    def ontArg = ontFiles ? "--ul ${ontFiles.join(',')}" : ""

    // Hi-C logic
    def hicMergeCmds = ""
    def hicArgs = ""
    def asmprefix = "${sample}"

    def hicR1s = []
    def hicR2s = []

    if (meta.hic && meta.hic.size() > 0) {
        meta.hic.each { run ->
          def (r1, r2) = run.file.tokenize(';')
          hicR1s << r1
          hicR2s << r2
        }

        asmprefix = "${sample}.hic"

        if (hicR1s.size() > 1) {
          def hicR1Merged = "${sample}.hic_r1.merged.fastq.gz"
          def hicR2Merged = "${sample}.hic_r2.merged.fastq.gz"
          hicMergeCmds = """
          echo "Merging Hi-C R1 for ${sample} (${hicR1s.size()} files)"
          cat ${hicR1s.join(' ')} > ${hicR1Merged}
          echo "Merging Hi-C R2 for ${sample} (${hicR2s.size()} files)"
          cat ${hicR2s.join(' ')} > ${hicR2Merged}
          """
          hicArgs = "--h1 ${hicR1Merged} --h2 ${hicR2Merged}"
        } else {
          hicArgs = "--h1 ${hicR1s[0]} --h2 ${hicR2s[0]}"
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

      // Flatten PB files
    def pbFiles = meta.pb*.file
    def pbArg = pbFiles ? pbFiles.join(' ') : ""

    // Flatten ONT files
    def ontFiles = meta.ont*.file
    def ontArg = ontFiles ? "--ul ${ontFiles.join(',')}" : ""

    // Hi-C logic
    def hicMergeCmds = ""
    def hicArgs = ""
    def asmprefix = "${sample}"

    def hicR1s = []
    def hicR2s = []

    if (meta.hic && meta.hic.size() > 0) {
        meta.hic.each { run ->
          def (r1, r2) = run.file.tokenize(';')
          hicR1s << r1
          hicR2s << r2
        }

        asmprefix = "${sample}.hic"

        if (hicR1s.size() > 1) {
          def hicR1Merged = "${sample}.hic_r1.merged.fastq.gz"
          def hicR2Merged = "${sample}.hic_r2.merged.fastq.gz"
          hicMergeCmds = """
          echo "Merging Hi-C R1 for ${sample} (${hicR1s.size()} files)"
          cat ${hicR1s.join(' ')} > ${hicR1Merged}
          echo "Merging Hi-C R2 for ${sample} (${hicR2s.size()} files)"
          cat ${hicR2s.join(' ')} > ${hicR2Merged}
          """
          hicArgs = "--h1 ${hicR1Merged} --h2 ${hicR2Merged}"
        } else {
          hicArgs = "--h1 ${hicR1s[0]} --h2 ${hicR2s[0]}"
        }
    }

    """

    echo hifiasm --telo-m CCCTAA -o ${sample} -t ${task.cpus} ${ontArg} ${hicArgs} ${pbArg} 
    for hap in "" ".hap1" ".hap2"; do
        echo gfatools gfa2fa ${asmprefix}\${hap}.p_ctg.gfa
    done
    touch ${sample}.p_ctg.fasta ${sample}.hap1.p_ctg.fasta ${sample}.hap2.p_ctg.fasta
    touch ${sample}.p_ctg.gfa ${sample}.hap1.gfa ${sample}.hap2.gfa
    """
}
