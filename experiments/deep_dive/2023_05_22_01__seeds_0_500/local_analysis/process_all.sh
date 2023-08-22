COMPARE=1
SEED=93
START_DEPTH=730
STOP_DEPTH=750 #1010
LOCAL_SEEDS="1 2 3 4 5" 

CMP_FILENAME=seed_${SEED}__depths_${START_DEPTH}_${STOP_DEPTH}.csv

if [ ! ${COMPARE} -eq 0 ]
then
  #echo "start,stop,local_seed,behavior_lines_diff,execution_lines_diff,internal_lines_diff" > ${CMP_FILENAME}
  echo "seed,start,stop,local_seed,behavior_lines_diff,internal_lines_diff" > ${CMP_FILENAME}
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
      echo "Comparing depth ${DEPTH} and depth $(( ${DEPTH} + 1 ))"
      for LOCAL_SEED in ${LOCAL_SEEDS} 
      do
        BEHAVIOR_LINES=`cmp data/${SEED}/local_seed_${LOCAL_SEED}/doors_images/${DEPTH}.png data/${SEED}/local_seed_${LOCAL_SEED}/doors_images/$(( ${DEPTH} + 1 )).png | wc -l`
        # EXECUTION_LINES=`cmp data/${SEED}/local_seed_${LOCAL_SEED}/trace_source/${DEPTH}.txt data/${SEED}/local_seed_${LOCAL_SEED}/trace_source/$(( ${DEPTH} + 1 )).txt | wc -l`
        INTERNAL_LINES=`cmp data/${SEED}/local_seed_${LOCAL_SEED}/eval_traces/${DEPTH}.txt data/${SEED}/local_seed_${LOCAL_SEED}/eval_traces/$(( ${DEPTH} + 1 )).txt | wc -l`
        #if [ ! ${LINES} -eq 0 ]
        #then
          #echo "${DEPTH},$((${DEPTH} + 1)),${LOCAL_SEED},${BEHAVIOR_LINES},${EXECUTION_LINES},${INTERNAL_LINES}" >> ${CMP_FILENAME}
          echo "${SEED},${DEPTH},$((${DEPTH} + 1)),${LOCAL_SEED},${BEHAVIOR_LINES},${INTERNAL_LINES}" >> ${CMP_FILENAME}
        #fi
      done
    fi
  fi
done
