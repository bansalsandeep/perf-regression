#!/bin/bash

#cat report.html | grep -6 Throughput | tail -2 | awk -F "<|>" '{print "Benchmark-Name : " $5  " Throughput-Mean : "$9 }'

HTML_REPORT_FILE=${1:-report.html}

INDEX=0

benchmark_name=$(cat $HTML_REPORT_FILE | grep -5 Throughput | tail -1 | awk -F "<|>" '{print $5}')"_Vs_"$(cat $HTML_REPORT_FILE | grep -6 Throughput | tail -1 | awk -F "<|>" '{print $5}')

TPS_LHS=$(cat $HTML_REPORT_FILE | grep -5 Throughput | tail -1 | awk -F "<|>" '{print $9 }')
TPS_RHS=$(cat $HTML_REPORT_FILE | grep -6 Throughput | tail -1 | awk -F "<|>" '{print $9 }')

perf_change=$(echo $TPS_RHS/$TPS_LHS | bc -l)
perf_change=$(echo $perf_change-1 | bc -l)
perf_change=$(echo $perf_change*100 | bc -l)

if [ 1 -eq "$(echo "${perf_change} < 0" | bc)" ]
  then
	RESULT[${INDEX}]="FAILED"
  else
	RESULT[${INDEX}]="PASSED"
  fi

echo $benchmark_name,$TPS_LHS,$TPS_RHS,$perf_change,${RESULT[${INDEX}]}
