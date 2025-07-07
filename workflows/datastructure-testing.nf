//params.samplesheet = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg.csv"  // adjust as needed
params.samplesheet = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg-noillumina.csv"
include {hifiasm} from '/g/data/xl04/ka6418/github/ausargassembly/modules/test/hifiasmtest.nf'
include {shortreadtrimming} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/shortreadtrimming.nf'
include {shortreadstats} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/shortreadstats.nf'
include {kmer} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/kmer.nf'
include {longreadstats} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/longreadstats.nf'

kmermodes = ['17','21','25']

Channel
  .fromPath(params.samplesheet)
  .splitCsv(header: true)
  .map { row ->
    def sample = row.sample
    def tech   = row.tech.toLowerCase()
    def runid  = row.runid
    def file   = row.file
    tuple(sample, [tech: tech, entry: [runid: runid, file: file]])
  }
  .groupTuple()  // Groups all entries by sample
  .map { sample, entries ->
    def meta = [:]

    // Initialize all expected techs with empty lists
    ['ont', 'pb', 'hic', 'illumina'].each { tech ->
      meta[tech] = []
    }

    // Fill in actual data
    entries.each { it ->
      def tech = it.tech
      def entry = it.entry
      meta[tech] << entry
    }

    tuple(sample, meta)
  }
  .set { meta_ch }



workflow {
  
    meta_ch
    .flatMap { sample, meta ->
      meta.collectMany { tech, runs ->
        runs.collect { run ->
          tuple(sample, tech, run.runid, run.file)
        }
      }
    }
    .set { flattened_meta_ch }

    flattened_meta_illumina_ch = flattened_meta_ch.filter { sample, tech, runid, file ->
    tech == 'illumina'
    }

    flattened_meta_other_ch = flattened_meta_ch.filter { sample, tech, runid, file ->
    tech != 'illumina'
    }

    trimmed_illumina_ch = shortreadtrimming(flattened_meta_illumina_ch).map { sample, tech, runid, r1, r2 ->
          def joined = "${r1.name};${r2.name}"
          tuple(sample, tech, runid, joined)
        }


    flattened_meta_ch = flattened_meta_other_ch.mix(trimmed_illumina_ch)

    meta_ch = flattened_meta_ch
    .map { sample, tech, runid, file -> tuple(sample, [tech: tech, run: [runid: runid, file: file]]) }
    .groupTuple()
    .map { sample, items ->
      def meta = ['ont': [], 'pb': [], 'hic': [], 'illumina': []]
      items.each { entry ->
        def tech = entry.tech
        def run  = entry.run
        meta[tech] << run
      }
      tuple(sample, meta)
    }
    
    meta_ch.flatMap { sample, meta ->
      meta.collectMany { tech, runs ->
        runs.collect { run ->
          tuple(sample, tech, run.runid, run.file)
        }
      }
    }
    .set { flattened_meta_ch }

    shortstatsch = shortreadstats(flattened_meta_ch)
    longstatsch = longreadstats(flattened_meta_ch)

    meta_ch
    .flatMap { sample, meta ->
      meta.collect { tech, runs ->
        def files = runs*.file 
        tuple(sample, tech, files)
      }
    }
    .set { sample_tech_files_ch }

    kmerch = kmer(sample_tech_files_ch,kmermodes)

    hifiasmch = hifiasm(meta_ch)[0]

    hifiasmch
    .map { sample, meta_raw, primary, hap1, hap2 ->
      def meta_asm = [
      primary: primary,
        hap1: hap1,
        hap2: hap2
      ]
      tuple(sample, meta_raw, meta_asm)
    }
    .set { sample_meta_asm_ch }

  //ADAPTERS
    meta_ch
    .flatMap { sample, meta ->
      meta.collect { tech, runs ->
        def files = runs*.file
        tuple(sample, tech, files)
      }
    }
    .set { sample_tech_files_ch }

    //sample_tech_files_ch.view()


    meta_ch
    .flatMap { sample, meta ->
      meta.collect { tech, runs ->
        def runids = runs*.runid
        def files = runs*.file
        tuple(sample, tech, runids, files)
      }
    }
    .set { sample_tech_runids_files_ch }

    //sample_tech_runids_files_ch.view()

    //hifiasmch = hifiasm(meta_ch)[0]

    //hifiasmch
    //.map { sample, meta_raw, primary, hap1, hap2 ->
    //  def meta_asm = [
    //   primary: primary,
    //    hap1: hap1,
    //    hap2: hap2
    //  ]
    //  tuple(sample, meta_raw, meta_asm)
    //}
    //.set { sample_meta_asm_ch }

    //ample_meta_asm_ch.view()


  //ADAPTERS


}
