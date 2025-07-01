//add pacbio dry run, make download.sh scripts on test data and make config & run tests on Gadi
//and then plug in the real scripts, make it compliant with versions
//document,push,version and we are all set to go.
//test download bpa and then polish the processes, add software versions. add hic and then we are golden.
//sql queries need to be added. 

include {fast52blow5} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/fast52blow5.nf'
include {ontbasecall} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/ontbasecall.nf'
include {pbindex; ccs; actc; deepconsensus; concatFastq; pacbioadaptertrim} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/pbdeepconsensus.nf'


workflow {

        
        def ont_exists = file(params.ontmetadata).exists()
        def pb_exists  = file(params.pbmetadata).exists()
        // Input checks
        def run_ont = file(params.ontmetadata).exists()
        def run_pb  = file(params.pbmetadata).exists()
        // Channels
        def ont_ch = Channel.fromPath(params.ontmetadata).splitCsv(header:true)
        def pb_ch  = Channel.fromPath(params.pbmetadata).splitCsv(header:true)
        ont_ch.view()
        pb_ch.view()

        // Trigger individual workflows based on inputs
        if (run_ont) {
            ontblow5  = fast52blow5(ont_ch)
            ontfastq  = ontbasecall(ontblow5)
        }

        if (run_pb) {
            pbindexCh = pbindex(pb_ch)[0]
            idChannel = Channel.from(1..(params.chunks as Integer))
            pbindexCh = pbindexCh.combine(idChannel)
            ccsbamCh = ccs(pbindexCh)
            actcCh = actc(ccsbamCh)
            deepconsensusCh = deepconsensus(actcCh)
            deepconsensusCh = deepconsensusCh.groupTuple(by: [0, 1, 2])
            fastqCh = concatFastq(deepconsensusCh)
            trimmedfastCh = pacbioadaptertrim(fastqCh)[0]
        }



}