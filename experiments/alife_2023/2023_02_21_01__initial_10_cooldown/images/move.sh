#!/bin/bash

for NUM in {1..200}
do
  mv ${NUM}/out.png rep_${NUM}.png
  rm ${NUM} -r
done
