//stub file with illumina
//params.samplesheet = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg.csv" 
//stub file without illumina
//params.samplesheet = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg-noillumina.csv"

//real data
params.samplesheet = "/g/data/xl04/ka6418/github/ausargassembly/metadata/assembly-fixed-tiliqua-fastq-29july-tiliqua-withouttrim.csv"
params.analysisdir = "/g/data/xl04/genomeprojects"
params.rawdir = "/g/data/xl04/bpadownload2025"

include {hifiasm} from '/g/data/xl04/ka6418/github/ausargassembly/modules/test/hifiasmtest.nf'
include {shortreadtrimming} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/shortreadtrimming.nf'
include {shortreadstats} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/shortreadstats.nf'
include {kmerlongread; kmershortread} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/kmer.nf'
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
  .set { meta_ch_temp }



workflow {
  
    meta_ch_temp
    .flatMap { sample, meta ->
      meta.collectMany { tech, runs ->
        runs.collect { run ->
          tuple(sample, tech, run.runid, run.file)
        }
      }
    }
    .set { flattened_meta_ch_temp }

    flattened_meta_illumina_ch = flattened_meta_ch_temp.filter { sample, tech, runid, file ->
    tech == 'illumina'
    }

    flattened_meta_other_ch = flattened_meta_ch_temp.filter { sample, tech, runid, file ->
    tech != 'illumina'
    }

    trimmed_illumina_ch = shortreadtrimming(flattened_meta_illumina_ch).map { sample, tech, runid, r1, r2 ->
          def joined = "${r1};${r2}"
          tuple(sample, tech, runid, joined)
        }


    flattened_meta_ch_temp2 = flattened_meta_other_ch.mix(trimmed_illumina_ch)

    meta_ch = flattened_meta_ch_temp2
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
    //longstatsch = longreadstats(flattened_meta_ch)

    meta_ch
    .flatMap { sample, meta ->
      meta.collect { tech, runs ->
        def files = runs*.file
        // Limit Illumina to max 6 pairs
        if (tech == 'illumina' && files.size() > 6) {
          files = files.take(5)
        }
        tuple(sample, tech, files)
      }
    }
    .set { sample_tech_files_ch }

    //kmerlongreadch = kmerlongread(sample_tech_files_ch,kmermodes)
    kmershortreadch = kmershortread(sample_tech_files_ch,kmermodes)

    //hifiasmch = hifiasm(meta_ch)[0]

    //hifiasmch
    //.map { sample, meta_raw, primary, hap1, hap2 ->
    //  def meta_asm = [
    //  primary: primary,
    //    hap1: hap1,
    //    hap2: hap2
    //  ]
    //  tuple(sample, meta_raw, meta_asm)
    //}
    //.set { sample_meta_asm_ch }


}
