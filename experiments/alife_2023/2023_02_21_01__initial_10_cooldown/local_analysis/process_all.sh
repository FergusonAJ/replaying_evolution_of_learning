COMPARE=1
SEED=4
START_DEPTH=104
STOP_DEPTH=195
LOCAL_SEEDS="1 2 6 23022101000001" 

if [ ! ${COMPARE} -eq 0 ]
then
  echo "start,stop,lines,local_seed"
fi
for DEPTH in `seq ${START_DEPTH} ${STOP_DEPTH}`
do
  if [ ${COMPARE} -eq 0 ]
  then
    echo "Starting depth ${DEPTH}"
    for LOCAL_SEED in ${LOCAL_SEEDS} 
    do
      echo "${LOCAL_SEED}" > random_seed.txt
      ./process_one.sh ${SEED} ${DEPTH}
    done
  else # Compare
    if [ ! ${DEPTH} -eq ${STOP_DEPTH} ]
    then
      for LOCAL_SEED in ${LOCAL_SEEDS} 
      do
        LINES=`diff data/${SEED}/local_seed_${LOCAL_SEED}/trace_source/${DEPTH}.txt data/${SEED}/local_seed_${LOCAL_SEED}/trace_source/$(( ${DEPTH} + 1 )).txt | wc -l`
        if [ ! ${LINES} -eq 0 ]
        then
          echo "${DEPTH},$((${DEPTH} + 1)),${LINES},${LOCAL_SEED}"
        fi
      done
    fi
  fi
done
