#!/bin/bash

BASELINE_VERSION=${1:-3.6.2}
MASTER_VERSION=${2:-3.7.2}
TEST_DIR=${3:-tests}
outputDir=${4:-comparisionOutputDir}
REPORT_CSV=${5:-report.csv}
REPORT_HTML=${6:-perf-regression-report.html}

for TEST_NAME in ${TEST_DIR}/*.*
do

TEST_NAME=$(echo "${TEST_NAME}" | cut -d'.' -f1  | cut -d'/' -f2)

echo "**********RUNNING TEST : "$TEST_NAME "***************"

#Runing baseline test
echo "VERSION_SPEC=git=v"${BASELINE_VERSION} >> simulator.properties
./run 1 1 1m ${TEST_DIR}/${TEST_NAME} ${BASELINE_VERSION}_${TEST_NAME}

#Deleting baseline specific simulator properties
rm simulator.properties

#Runing Master version test
echo "VERSION_SPEC=git=v"${MASTER_VERSION} >> simulator.properties
./run 1 1 1m ${TEST_DIR}/${TEST_NAME} ${MASTER_VERSION}_${TEST_NAME}

#Running benchmark/comparison report genertion report tool
$SIMULATOR_HOME/bin/benchmark-report ${outputDir}_${TEST_NAME} ${BASELINE_VERSION}_${TEST_NAME} ${MASTER_VERSION}_${TEST_NAME}

#Parse benchmark/comparison report and get performance change
./parseBenchmarkingReport.sh ${outputDir}_${TEST_NAME}/report.html >> ${REPORT_CSV}

done



echo "<html><table border=\"1\">" >> ${REPORT_HTML}
echo "<tr bgcolor=/"#FF0000/"><td>BENCHMARK_NAME</td><td>"${BASELINE_VERSION}"</td><td>"${MASTER_VERSION}"</td><td>PERF REGRESSION</td><td>RESULT</td></tr>" >> ${REPORT_HTML}
    while read INPUT ; do
            echo "<tr><td>${INPUT//,/</td><td>}</td></tr>" >> ${REPORT_HTML}
    done < ${REPORT_CSV}
    echo "</table></html>" >> ${REPORT_HTML}

