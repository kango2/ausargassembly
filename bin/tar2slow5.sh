set -euo pipefail
set -x

#uses PBS_NCPUS

while getopts f:p:t:o:n: flag; do
  case "${flag}" in
    f) FAILTAR=${OPTARG} ;;
    p) PASSTAR=${OPTARG} ;;
    t) TEMPDIR=${OPTARG} ;;
    o) OUTDIR=${OPTARG} ;;
    n) FINALBLOW5=${OPTARG} ;;
    *) echo "Invalid flag used."; exit 1 ;;
  esac
done


if [[ -z "${FAILTAR:-}" || -z "${PASSTAR:-}" || -z "${TEMPDIR:-}" || -z "${OUTDIR:-}" || -z "${FINALBLOW5:-}" ]]; then
  echo "Usage: $0 -f FAILTAR -p PASSTAR -t TEMPDIR -o OUTDIR -n FINALBLOW5"
  exit 1
fi

mkdir -p "$TEMPDIR" "$OUTDIR"
cd "$TEMPDIR"

FAILDIR="${TEMPDIR}/fail"
PASSDIR="${TEMPDIR}/pass"
mkdir -p "$FAILDIR" "$PASSDIR"

module load slow5tools

tar -xf "$FAILTAR" -C "$FAILDIR"
tar -xf "$PASSTAR" -C "$PASSDIR"

find "$FAILDIR" "$PASSDIR" -name "*.fast5.gz" -exec pigz -d -p "${PBS_NCPUS:-4}" -f {} +

find "$FAILDIR" "$PASSDIR" -name "*.fast5" | xargs -P "${PBS_NCPUS:-4}" -I{} bash -c 'slow5tools f2s "{}" -o "$(basename "{}" .fast5).blow5"'

slow5tools merge -t "${PBS_NCPUS:-4}" -o "${OUTDIR}/${FINALBLOW5}" ./*.blow5
