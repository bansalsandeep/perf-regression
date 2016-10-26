#!/bin/bash

BASELINE_VERSION=${1:-3.7.2}
MASTER_VERSION=${2:-master}
TEST_DIR=${3:-tests}
TEST_RESULT_DIR=${4:-tests-results}
COMPARISON_REPORT_DIR=${5:-comparison-report}
REPORT_CSV=${6:-report.csv}
REPORT_HTML=${7:-perf-regression-report.html}

#Creating machines on AWS
echo "Creating 2 machines on AWS using command : provisioner --scale 2 "
cp template_simulator.properties simulator.properties
$SIMULATOR_HOME/bin/provisioner --scale 2
echo "Machine creation completed."

for TEST_NAME in ${TEST_DIR}/*.*
do

    TEST_NAME=$(echo "${TEST_NAME}" | cut -d'.' -f1  | cut -d'/' -f2)

    echo "**********RUNNING TEST : "$TEST_NAME "***************"

    #Deleting baseline specific simulator properties
    rm simulator.properties
    cp template_simulator.properties simulator.properties

    #Runing baseline test
    echo "VERSION_SPEC=git=v"${BASELINE_VERSION} >> simulator.properties
    cat simulator.properties
    ./run 1 1 1m ${TEST_DIR}/${TEST_NAME} ${TEST_RESULT_DIR}/${TEST_NAME}/${BASELINE_VERSION}

    #Deleting master specific simulator properties
    rm simulator.properties
    cp template_simulator.properties simulator.properties

    #Runing Master version test
    echo "VERSION_SPEC=git="${MASTER_VERSION} >> simulator.properties
    cat simulator.properties
    ./run 1 1 1m ${TEST_DIR}/${TEST_NAME} ${TEST_RESULT_DIR}/${TEST_NAME}/${MASTER_VERSION}

    #Cleaning simulator.properties
    rm simulator.properties

    #Running benchmark/comparison report genertion report tool
    $SIMULATOR_HOME/bin/benchmark-report ${TEST_RESULT_DIR}/${TEST_NAME}/${COMPARISON_REPORT_DIR} ${TEST_RESULT_DIR}/${TEST_NAME}/${BASELINE_VERSION} ${TEST_RESULT_DIR}/${TEST_NAME}/${MASTER_VERSION}

    #Parse benchmark/comparison report and get performance change
    ./parseBenchmarkingReport.sh ${TEST_NAME} ${TEST_RESULT_DIR}/${TEST_NAME}/${COMPARISON_REPORT_DIR}/report.html >> ${TEST_RESULT_DIR}/${REPORT_CSV}

done


echo "<html><table border=\"1\">" >> ${TEST_RESULT_DIR}/${REPORT_HTML}
echo "<tr bgcolor=/"#FF0000/"><td>BENCHMARK_NAME</td><td>"${BASELINE_VERSION}"</td><td>"${MASTER_VERSION}"</td><td>PERF REGRESSION</td><td>RESULT</td></tr>" >> ${TEST_RESULT_DIR}/${REPORT_HTML}
    while read INPUT ; do
            echo "<tr><td>${INPUT//,/</td><td>}</td></tr>" >> ${TEST_RESULT_DIR}/${REPORT_HTML}
    done < ${TEST_RESULT_DIR}/${REPORT_CSV}
echo "</table></html>" >> ${TEST_RESULT_DIR}/${REPORT_HTML}
