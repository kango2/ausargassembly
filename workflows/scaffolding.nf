include {contighicmap} from '/g/data/xl04/ka6418/github/ausargassembly/modules/scaffolding/contighicmap.nf'
include {hicmapping} from '/g/data/xl04/ka6418/github/ausargassembly/modules/scaffolding/hicmapping.nf'
include {contigtoscaffold} from '/g/data/xl04/ka6418/github/ausargassembly/modules/scaffolding/contigtoscaffold.nf'
include {scaffoldhicmap} from '/g/data/xl04/ka6418/github/ausargassembly/modules/scaffolding/scaffoldhicmap.nf'

//STUB//
params.rawcsv = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg.csv"
params.asmcsv = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg-assembly.csv"
//STUB//

//SMALL TEST DATA - PB,ONT,ILLUMINA using PV2.1 assembly//
//params.rawcsv = "/g/data/xl04/ka6418/testing/tempjobfs/testpack-readsandasm/fastq.csv"
//params.asmcsv = "/g/data/xl04/ka6418/testing/tempjobfs/testpack-readsandasm/asm.csv"
//

//PRODUCTION DATASET
//params.rawcsv = "/g/data/xl04/ka6418/github/ausargassembly/metadata/assembly-fastq-8july.csv"
//params.asmcsv = "/g/data/xl04/ka6418/github/ausargassembly/metadata/assembly-fasta-22july.csv"
//

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
  .set { hic_mapping_ch }

  contighicmapch = contighicmap(hic_mapping_ch)
  hicmappingch = hicmapping(hic_mapping_ch)[0]
  contigtoscaffoldch = contigtoscaffold(hicmappingch)
  scaffoldhicmapch = scaffoldhicmap(contigtoscaffoldch)

  contigtoscaffoldch
  .map { sample, asmtype, assembler, fasta, bin, agp ->
    def yahs_entry = [(asmtype): [fasta: fasta]]
    tuple(sample, yahs_entry)
  }
  .groupTuple()
  .map { sample, entries ->
    def merged = [:]
    entries.each { entry ->
      entry.each { asmtype, data -> merged[asmtype] = data }
    }
    def meta_asm = ['yahs': merged]
    tuple(sample, meta_asm)
  }
  .set { yahs_asm_ch }

  full_metadata_ch
  .join(yahs_asm_ch)
  .map { sample, meta, yahs_asm ->
    def new_asm = meta.asm + yahs_asm
    tuple(sample, [raw: meta.raw, asm: new_asm])
  }
  .set { updated_full_metadata_ch }

  updated_full_metadata_ch
  .flatMap { sample, meta ->

    def output = []

    // ONLY process yahs assembler
    meta.asm.each { assembler, asmtypes_map ->
      if (assembler != 'yahs') return  // Skip non-yahs assemblers

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

  


  


  


  
    
}

