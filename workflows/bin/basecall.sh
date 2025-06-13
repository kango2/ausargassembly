#!/bin/bash
#PBS -P te53
#PBS -N basecallv2
#PBS -q dgxa100
#PBS -l ncpus=128
#PBS -l ngpus=8
#PBS -l mem=2000GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/xl04+gdata/te53
#PBS -j oe

set -x
module load buttery-eel/0.7.1+dorado7.4.12 htslib seqkit

# terminate script
die() {
    echo "$1" >&2
    exit 1
}

#MODEL=dna_r10.4.1_e8.2_400bps_5khz_sup.cfg
#PORT=5000
#MODE=SUP

get_free_port() {
    for port in $(seq 5000 65000); do
        echo "trying port $port" >&2
        PORT=$port
        ss -lpna | grep -q ":$port " || break
    done
}

get_free_port
test -z "${PORT}" && die "Could not find a free port"
echo "Using port ${PORT}"

ONT_DORADO_PATH=$(which dorado_basecall_server | sed "s/dorado\_basecall\_server$//")/
${ONT_DORADO_PATH}/dorado_basecall_server --version || die "Could not find dorado_basecall_server"

test -e ${MERGED_SLOW5} || die "${MERGED_SLOW5} not found. Exiting."

cd ${OUTDIR} || die "${OUTDIR} not found. Exiting."


FINAL_FASTQ="${OUTDIR}/${OUTFILE}.fastq"
INTERMEDIATE_FASTQ="${OUTDIR}/${OUTFILE}"
FINAL_FASTQ_PASS="${OUTDIR}/${OUTFILE}_pass.fastq"
FINAL_FASTQ_FAIL="${OUTDIR}/${OUTFILE}_fail.fastq"

RETRY_COUNT=10000
for i in $(seq 1 ${RETRY_COUNT}); do
    
    OUTPUT_FASTQ="${INTERMEDIATE_FASTQ}-RETRY${i}.fastq"

    if [ $i -eq 1 ]; then
        buttery-eel -i ${MERGED_SLOW5} -o "${OUTPUT_FASTQ}" -g ${ONT_DORADO_PATH} \
            --port ${PORT} --use_tcp --config ${MODEL} -x cuda:all \
            --slow5_threads 10 --slow5_batchsize 2000 --procs 10 --profile --trim_adapters --max_batch_time 10000
    else
        PREV_OUTPUT_FASTQ="${INTERMEDIATE_FASTQ}-RETRY$((i-1)).fastq"

        if [ ! -f "${PREV_OUTPUT_FASTQ}" ]; then
            echo "Error: Previous output file ${PREV_OUTPUT_FASTQ} not found. Exiting script."
            exit 1
        fi

        buttery-eel -i ${MERGED_SLOW5} -o "${OUTPUT_FASTQ}" -g ${ONT_DORADO_PATH} \
            --port ${PORT} --use_tcp --config ${MODEL} -x cuda:all \
            --slow5_threads 10 --slow5_batchsize 2000 --procs 10 --trim_adapters --profile --resume "${PREV_OUTPUT_FASTQ}" --max_batch_time 20000
    fi

	if [ $? -eq 0 ]; then
        echo "Basecalling succeeded on retry $i" 
        break 
    else
        echo "Basecalling failed on retry $i. Retrying..."
    fi

done

cat *RETRY*fastq >> ${FINAL_FASTQ}

awk 'NR % 4 == 1 {split($0, a, "mean_qscore="); if (a[2] >= 7) print substr($1, 2); }' ${FINAL_FASTQ} > pass_ids.txt
awk 'NR % 4 == 1 {split($0, a, "mean_qscore="); if (a[2] < 7) print substr($1, 2); }' ${FINAL_FASTQ} > fail_ids.txt
seqkit grep -f pass_ids.txt ${FINAL_FASTQ} -o ${FINAL_FASTQ_PASS}
seqkit grep -f fail_ids.txt ${FINAL_FASTQ} -o ${FINAL_FASTQ_FAIL}

md5sum ${FINAL_FASTQ_PASS} > ${FINAL_FASTQ}.md5
md5sum ${FINAL_FASTQ_FAIL} >> ${FINAL_FASTQ}.md5

bgzip --index -@ ${PBS_NCPUS} ${FINAL_FASTQ_PASS}
bgzip --index -@ ${PBS_NCPUS} ${FINAL_FASTQ_FAIL}

md5sum "${FINAL_FASTQ_PASS}.gz" >> ${FINAL_FASTQ}.md5
md5sum "${FINAL_FASTQ_PASS}.gz.gzi" >> ${FINAL_FASTQ}.md5
md5sum "${FINAL_FASTQ_FAIL}.gz" >> ${FINAL_FASTQ}.md5
md5sum "${FINAL_FASTQ_FAIL}.gz.gzi" >> ${FINAL_FASTQ}.md5

rm *RETRY*fastq