include {alignreads} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/alignreads.nf'

//STUB//
//params.rawcsv = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg.csv"
//params.asmcsv = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg-assembly.csv"
//STUB//

//SMALL TEST DATA - PB,ONT,ILLUMINA using PV2.1 assembly//
params.rawcsv = "/g/data/xl04/ka6418/testing/tempjobfs/testpack-readsandasm/fastq.csv"
params.asmcsv = "/g/data/xl04/ka6418/testing/tempjobfs/testpack-readsandasm/asm.csv"

// ========== RAW DATA PARSER ========== //
Channel
  .fromPath(params.rawcsv) // Your raw data CSV
  .splitCsv(header: true)
  .map { row ->
    def sample = row.sample
    def tech   = row.tech.toLowerCase()
    def runid  = row.runid
    def file   = row.file
    tuple(sample, [tech: tech, entry: [runid: runid, file: file]])
  }
  .groupTuple()
  .map { sample, entries ->
    def meta_raw = ['ont': [], 'pb': [], 'hic': [], 'illumina': []]
    entries.each { it ->
      def tech = it.tech
      def entry = it.entry
      meta_raw[tech] << entry
    }
    tuple(sample, meta_raw)
  }
  .set { meta_raw_ch }

// ========== ASSEMBLY PARSER ========== //
Channel
  .fromPath(params.asmcsv)
  .splitCsv(header: true)
  .map { row ->
    def sample    = row.sample
    def assembler = row.assembler.toLowerCase()
    def asmtype   = row.asmtype.toLowerCase()
    def path      = file(row.path)
    tuple(sample, assembler, asmtype, path)
  }. groupTuple(by : [0,1])
    .map { sample, assembler, asmtypes, paths ->
    def asm_map = [:]
    asmtypes.eachWithIndex { asmtype, i ->
      asm_map[asmtype] = [fasta: paths[i]]
    }
    def meta_asm = [(assembler): asm_map]
    tuple(sample, meta_asm)
  }
  .set { meta_asm_ch }


meta_raw_ch
  .join(meta_asm_ch)
  .map { sample, meta_raw, meta_asm ->
    tuple(sample, [raw: meta_raw, asm: meta_asm])
  }
  .set { full_metadata_ch }



workflow {

  full_metadata_ch
  .flatMap { sample, meta ->

    def output = []

    // for each assembler (usually only 'hifiasm')
    meta.asm.each { assembler, asmtypes_map ->

      // for each asmtype (primary, hap1, hap2)
      asmtypes_map.each { asmtype, asmdata ->
        def asmfasta = asmdata.fasta

        // for each tech with available reads
        meta.raw.each { tech, runs ->
          if (runs && runs.size() > 0) {
            def reads = runs.collect { it.file }
            output << tuple(sample, tech, assembler, asmtype, reads, asmfasta)
          }
        }
      }

    }

    return output
  }
  .set { alignreads_input_ch }

  alignreads_input_ch.view()
   
  alignedreads = alignreads(alignreads_input_ch)[0]































  
  alignedreads.map { sample, tech, assembler, asmtype, bam ->
      tuple(sample, [tech: tech, assembler: assembler, asmtype: asmtype, bam: bam])
    }
    .groupTuple()
    .set { grouped_bam_map }

  full_metadata_ch
  .combine(grouped_bam_map)
  .map { sample, meta, bam_entries ->

    bam_entries.each { entry ->
      def tech = entry.tech
      def assembler = entry.assembler
      def asmtype = entry.asmtype
      def bam = entry.bam

      if (!meta.asm[assembler][asmtype].containsKey('alignment')) {
        meta.asm[assembler][asmtype]['alignment'] = [:]
      }
      meta.asm[assembler][asmtype]['alignment'][tech] = bam
    }

    tuple(sample, meta)
  }
  .set { enriched_metadata_ch }



}




