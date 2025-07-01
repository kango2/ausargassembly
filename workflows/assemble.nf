include {hifiasm} from '/g/data/xl04/ka6418/github/ausargassembly/modules/assembly/hifiasm.nf'

params.samplesheet = "/g/data/xl04/ka6418/ausargassembly/devphase2/testcsv-assemblenf.csv"

Channel
  .fromPath(params.samplesheet)
  .splitCsv(header:true)
  .map { row ->
    def meta = [
      ont     : row.ont_reads    ? row.ont_reads.tokenize(';')   : [],
      pb      : row.pb_reads     ? row.pb_reads.tokenize(';')    : [],
      hic_r1  : row.hic_r1       ? row.hic_r1.tokenize(';')      : [],
      hic_r2  : row.hic_r2       ? row.hic_r2.tokenize(';')      : [],
      illum_r1: row.illum_r1     ? row.illum_r1.tokenize(';')    : [],
      illum_r2: row.illum_r2     ? row.illum_r2.tokenize(';')    : []
    ]
    tuple(row.sample, meta)
  }
  .set { meta_ch }


workflow {

    meta_ch.view()
    //hifiasm(meta_ch)

}

