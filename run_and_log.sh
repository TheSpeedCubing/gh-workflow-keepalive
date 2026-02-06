#!/bin/bash

cd "$(dirname "$0")"

mkdir -p logs

currenttime=$(date +"%Y-%m-%d_%H-%M-%S")

logfile="logs/${currenttime}.log"

./run.sh > "$logfile" 2>&1