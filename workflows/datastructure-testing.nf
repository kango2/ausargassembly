params.samplesheet = "/g/data/xl04/ka6418/ausargassembly/assemblydev/sampledataausarg.csv"  // adjust as needed

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
    entries.each { it ->
      def tech = it.tech
      def entry = it.entry
      if (!meta.containsKey(tech)) {
        meta[tech] = []
      }
      meta[tech] << entry
    }
    tuple(sample, meta)
  }
  .set { meta_ch }

workflow {


  //meta_ch.view()


  // generates tuples of [sample, tech, runid, file]
  meta_ch
  .flatMap { sample, meta ->
    meta.collectMany { tech, runs ->
      runs.collect { run ->
        tuple(sample, tech, run.runid, run.file)
      }
    }
  }
  .set { flat_tech_run_file_ch }

  //flat_tech_run_file_ch.view()

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

  sample_tech_runids_files_ch.view()

  





}
