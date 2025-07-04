include {longreadstats} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/longreadstats.nf'
include {shortreadstats} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/shortreadstats.nf'
include {kmer} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/kmer.nf'

params.shortread = "/g/data/xl04/ka6418/ausargassembly/assemblydev/shortreadfiles.csv"
params.longread = "/g/data/xl04/ka6418/ausargassembly/assemblydev/longreadfiles.csv"

kmercounts = [17,21,25]

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

    trimmedshortreadch = shortreadtrimming(shortreadch)
    longreadstats(longreadch)
    shortreadstats(trimmedshortreadch)

    // Standardize both channels to 3-element tuples: [sample, tech, file or file list]
    longread_flat = longreadch.map { sample, tech, runid, f ->
        [sample, tech, f]
    }

    shortread_flat = trimmedshortreadch.map { sample, tech, runid, r1, r2 ->
        [sample, tech, [r1, r2]]
    }
    // Merge and group by sample and tech
    merged_flat = longread_flat.mix(shortread_flat)

    merged_grouped = merged_flat.groupTuple(by: [0, 1]).map { sample,tech,files ->
        return tuple (sample, tech, files.flatten())
    }

    merged_grouped.view()

    kmerch = kmer(merged_grouped, kmercounts)
    
    kmerch.view()

}