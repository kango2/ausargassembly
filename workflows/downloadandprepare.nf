//add pacbio dry run, make download.sh scripts on test data and make config & run tests on Gadi
//and then plug in the real scripts, make it compliant with versions
//document,push,version and we are all set to go.
//test download bpa and then polish the processes, add software versions. add hic and then we are golden.
//sql queries need to be added. 

include { bpadownload_ont; bpadownload_hic; bpadownload_pb } from '/g/data/xl04/ka6418/github/ausargassembly/modules/bpadownload/bpadownload.nf'
include {fast52blow5} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/fast52blow5.nf'
include {ontbasecall} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/ontbasecall.nf'
include {pbindex; ccs; actc; deepconsensus; concatFastq; pacbioadaptertrim} from '/g/data/xl04/ka6418/github/ausargassembly/modules/rawdata/pbdeepconsensus.nf'


workflow {

        
        def ont_exists = file(params.ontmetadata).exists()
        def pb_exists  = file(params.pbmetadata).exists()
        def hic_exists = file(params.hicmetadata).exists()

        // Input checks
        def run_ont = file(params.ontmetadata).exists()
        def run_pb  = file(params.pbmetadata).exists()
        def run_hic = file(params.hicmetadata).exists()

        // Channels
        def ont_ch = run_ont ? Channel.fromPath(params.ontmetadata).splitCsv(header:true) : Channel.empty()
        def pb_ch  = run_pb  ? Channel.fromPath(params.pbmetadata).splitCsv(header:true)  : Channel.empty()
        def hic_ch = run_hic ? Channel.fromPath(params.hicmetadata).splitCsv(header:true) : Channel.empty()

        // Workflow mode
        def workflow_mode = [
            run_ont ? 'ONT' : null,
            run_pb  ? 'PB'  : null,
            run_hic ? 'HIC' : null
        ].findAll().join('_')

        println "🧭 Workflow mode inferred as: ${workflow_mode}"

        // Trigger individual workflows based on inputs
        if (run_ont) {
            def ontfast5  = bpadownload_ont(ont_ch)
            def ontblow5  = fast52blow5(ontfast5)
            def ontfastq  = ontbasecall(ontblow5)
        }

        if (run_pb) {
            pbsubreadsCh = bpadownload_pb(pb_ch)
            pbindexCh = pbindex(pbsubreadsCh)[0]
            idChannel = Channel.from(1..(params.chunks as Integer))
            pbindexCh = pbindexCh.combine(idChannel)
            ccsbamCh = ccs(pbindexCh)
            actcCh = actc(ccsbamCh)
            deepconsensusCh = deepconsensus(actcCh)
            deepconsensusCh = deepconsensusCh.groupTuple(by: [0, 1, 2])
            fastqCh = concatFastq(deepconsensusCh)
            trimmedfastCh = pacbioadaptertrim(fastqCh)[0]
        }

        if (run_hic) {
            def hicmetadata = bpadownload_hic(hic_ch)
        }

        //sql query channels? 
}