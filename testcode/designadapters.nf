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
