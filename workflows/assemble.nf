include {hifiasm} from '/g/data/xl04/ka6418/github/ausargassembly/modules/assembly/hifiasm.nf'
include {longreadstats} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/longreadstats.nf'
include {shortreadstats} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/shortreadstats.nf'

//params.samplesheet = "/g/data/xl04/ka6418/ausargassembly/devphase2/testcsv-assemblenf.csv"

//Channel
// .fromPath(params.samplesheet)
//  .splitCsv(header:true)
//  .map { row ->
//    def meta = [
//      ont     : row.ont_reads    ? row.ont_reads.tokenize(';')   : [],
//      pb      : row.pb_reads     ? row.pb_reads.tokenize(';')    : [],
//      hic_r1  : row.hic_r1       ? row.hic_r1.tokenize(';')      : [],
//      hic_r2  : row.hic_r2       ? row.hic_r2.tokenize(';')      : [],
//      illum_r1: row.illum_r1     ? row.illum_r1.tokenize(';')    : [],
//      illum_r2: row.illum_r2     ? row.illum_r2.tokenize(';')    : []
//    ]
//    tuple(row.sample, meta)
//  }
//  .set { meta_ch }

params.shortread = "/g/data/xl04/ka6418/ausargassembly/assemblydev/shortreadfiles.csv"
params.longread = "/g/data/xl04/ka6418/ausargassembly/assemblydev/longreadfiles.csv"

Channel
    .fromPath(params.longread)
    .splitCsv(header: true)
    .map { row -> 
        def sample = row.sample
        def tech = row.tech
        def runid = row.runid
        def file = file(row.file)
        return [sample, tech, runid, file]
    }
    .set { longreadch }


Channel
    .fromPath(params.shortread)
    .splitCsv(header: true)
    .map { row -> 
        def sample = row.sample
        def tech = row.tech
        def runid = row.runid
        def r1 = file(row.r1file)
        def r2 = file(row.r2file)
        return [sample, tech, runid, r1, r2]
    }
    .set { shortreadch }


workflow {

  longreadstats(longreadch)
  shortreadstats(shortreadch)


  // Process long reads: ONT and PB
longreadch
    .map { sample, tech, runid, f ->
        def label = tech == "ONT" ? 'ont' :
                    tech == "PB"  ? 'pb'  : null
        [sample, label, f]
    }
    .filter { sample, label, f -> label != null }
    .set { long_meta_ch }

// Process short reads: Illumina and HiC
shortreadch
    .flatMap { sample, tech, runid, r1, r2 ->
        def items = []
        if (tech == "Illumina") {
            items << [sample, 'illum_r1', r1]
            items << [sample, 'illum_r2', r2]
        } else if (tech == "HIC") {
            items << [sample, 'hic_r1', r1]
            items << [sample, 'hic_r2', r2]
        }
        return items
    }
    .set { short_meta_ch }

// Combine and group
long_meta_ch
    .mix(short_meta_ch)
    .groupTuple()
    .map { sample, records ->
        def meta = [
            ont: [], pb: [], illum_r1: [], illum_r2: [], hic_r1: [], hic_r2: []
        ]
        for (def entry : records) {
            def label = entry[0]
            def val   = entry[1]
            meta[label] << val
        }
        tuple(sample, meta)
    }
    .set { meta_ch }


meta_ch.view()


}

