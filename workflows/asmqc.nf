include {alignreads} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/alignreads.nf'
include {bamdepth} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/bamdepth.nf'
include {merqury} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/merqury.nf'
include {inspector} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/inspector.nf'
include {gaps} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/gaps.nf'
include {busco} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/busco.nf'
include {gc} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/gc.nf'
include {asmtable} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/asmtable.nf'
include {seqtable} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/seqtable.nf'
include {srf} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/srf.nf'
include {telomeres} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/telomeres.nf'
include {univec} from '/g/data/xl04/ka6418/github/ausargassembly/modules/asmqc/univec.nf'

//STUB//
//params.rawcsv = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg.csv"
//params.asmcsv = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg-assembly.csv"
//STUB//

//SMALL TEST DATA - PB,ONT,ILLUMINA using PV2.1 assembly//
//params.rawcsv = "/g/data/xl04/ka6418/testing/tempjobfs/testpack-readsandasm/fastq.csv"
//params.asmcsv = "/g/data/xl04/ka6418/testing/tempjobfs/testpack-readsandasm/asm.csv"
//

//PRODUCTION DATASET
params.rawcsv = "/g/data/xl04/ka6418/github/ausargassembly/metadata/assembly-fastq-8july.csv"
params.asmcsv = "/g/data/xl04/ka6418/github/ausargassembly/metadata/assembly-fasta-22july.csv"

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
   
  alignedreads = alignreads(alignreads_input_ch)[0]
  depthch = bamdepth(alignedreads)


  full_metadata_ch
    .flatMap { sample, meta ->

      def output = []

      meta.asm.each { assembler, asmtypes_map ->

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
  merquryCh = merqury(meta_with_hap_ch,kmer)
  inspectorCh = inspector(meta_with_hap_ch)


  full_metadata_ch
  .flatMap { sample, meta ->
    def output = []

    // Loop over each assembler
    meta.asm.each { assembler, asmtypes_map ->

      // Loop over each asmtype (e.g., primary, hap1, hap2)
      asmtypes_map.each { asmtype, asmdata ->
        def asmfasta = asmdata.fasta
        output << tuple(sample, asmtype, assembler, asmfasta)
      }

    }

    return output
  }
  .set { asmfasta_ch }

  gaps(asmfasta_ch)
  busco(asmfasta_ch)
  gc(asmfasta_ch)
  asmtable(asmfasta_ch)
  seqtable(asmfasta_ch)
  srf(asmfasta_ch)
  telomeres(asmfasta_ch)
  univec(asmfasta_ch)

  


}




