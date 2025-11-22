NSPLIT=128 #Must be larger than the number of processes used during training
FILENAME=wikipedia_en_20231101.txt
INFILE=$CS511MP3/scripts/preprocess/${FILENAME}
TOKENIZER=bert-base-uncased
#TOKENIZER=bert-base-multilingual-cased
SPLITDIR=$CS511MP3/scripts/preprocess/tmp-tokenization-${TOKENIZER}-${FILENAME}/
OUTDIR=$CS511MP3/scripts/preprocess/encoded-data/${TOKENIZER}/$(echo "$FILENAME" | cut -f 1 -d '.')
NPROCESS=8

mkdir -p ${SPLITDIR}
echo ${INFILE}
split -a 3 -d -n l/${NSPLIT} ${INFILE} ${SPLITDIR}

pids=()

for ((i=0;i<$NSPLIT;i++)); do
    num=$(printf "%03d\n" $i);
    FILE=${SPLITDIR}${num};
    #we used --normalize_text as an additional option for mContriever
    python3 $CS511MP3/scripts/preprocess.py --tokenizer ${TOKENIZER} --datapath ${FILE} --outdir ${OUTDIR} &
    pids+=($!);
    if (( $i % $NPROCESS == 0 ))
    then
        for pid in ${pids[@]}; do
            wait $pid
        done
    fi
done

for pid in ${pids[@]}; do
    wait $pid
done

echo ${SPLITDIR}

rm -r ${SPLITDIR}
