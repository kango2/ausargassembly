include {contighicmap} from '/g/data/xl04/ka6418/github/ausargassembly/modules/scaffolding/contighicmap.nf'
include {hicmapping} from '/g/data/xl04/ka6418/github/ausargassembly/modules/scaffolding/hicmapping.nf'
include {contigtoscaffold} from '/g/data/xl04/ka6418/github/ausargassembly/modules/scaffolding/contigtoscaffold.nf'
include {scaffoldhicmap} from '/g/data/xl04/ka6418/github/ausargassembly/modules/scaffolding/scaffoldhicmap.nf'
include {alignreads as alignreads_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/alignreads.nf'
include {bamdepth as bamdepth_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/bamdepth.nf'
include {merqury as merqury_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/merqury.nf'
include {inspector as inspector_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/inspector.nf'
include {gaps as gaps_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/gaps.nf'
include {busco as busco_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/busco.nf'
include {gc as gc_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/gc.nf'
include {asmtable as asmtable_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/asmtable.nf'
include {seqtable as seqtable_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/seqtable.nf'
include {srf as srf_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/srf.nf'
include {telomeres as telomeres_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/telomeres.nf'
include {univec as univec_scaf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/univec.nf'


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
  contigtoscaffoldch = contigtoscaffold(hicmappingch)[0]
  scaffoldhicmapch = scaffoldhicmap(contigtoscaffoldch)

  contigtoscaffoldch
  .map { sample, asmtype, assembler, contigs, scaffolds, bin, agp ->
    def yahs_entry = [(asmtype): [fasta: scaffolds]]
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

  alignedreads = alignreads_scaf(alignreads_input_ch)[0]
  depthch = bamdepth_scaf(alignedreads)

  updated_full_metadata_ch
  .flatMap { sample, meta ->

    def output = []

    meta.asm.each { assembler, asmtypes_map ->
     if (assembler != 'yahs') return
      // only proceed if primary is defined
      def primary = asmtypes_map.p?.fasta
      def h1 = asmtypes_map.h1?.fasta
      def h2 = asmtypes_map.h2?.fasta

      if (!primary) return []  // skip if no primary assembly

      meta.raw.each { tech, runs ->
        if (runs && runs.size() > 0) {
          def reads = runs.collect { it.file }
          output << tuple(sample, tech, assembler, reads, h1, h2)
        }
      }
    }

    return output
  }
  .set {meta_with_hap_ch}

  kmer = [17,21,25]
  merquryCh = merqury_scaf(meta_with_hap_ch,kmer)
  inspectorCh = inspector_scaf(meta_with_hap_ch)

  updated_full_metadata_ch
  .flatMap { sample, meta ->
    def output = []

    // Loop over each assembler
    meta.asm.each { assembler, asmtypes_map ->
    if (assembler != 'yahs') return

      // Loop over each asmtype (e.g., primary, hap1, hap2)
      asmtypes_map.each { asmtype, asmdata ->
        def asmfasta = asmdata.fasta
        output << tuple(sample, asmtype, assembler, asmfasta)
      }

    }

    return output
  }
  .set { asmfasta_ch }

  gaps_scaf(asmfasta_ch)
  busco_scaf(asmfasta_ch)
  gc_scaf(asmfasta_ch)
  asmtable_scaf(asmfasta_ch)
  seqtable_scaf(asmfasta_ch)
  srf_scaf(asmfasta_ch)
  telomeres_scaf(asmfasta_ch)
  univec_scaf(asmfasta_ch)

}

