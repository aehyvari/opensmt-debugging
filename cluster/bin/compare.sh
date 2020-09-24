#!/bin/bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

CLUSTER_BIN_ROOT=$(get_abs_path $(dirname $0))
PLOTTING_BIN_ROOT=${CLUSTER_BIN_ROOT}/../../plotting/bin

EXTRACTOR=${CLUSTER_BIN_ROOT}/extract_results_time_osmt2.sh
GNUPLOTTOR=${PLOTTING_BIN_ROOT}/make_scatterplot_time.py
PLOT_MAKEFILE=${PLOTTING_BIN_ROOT}/../Makefile

export epstopdf=${PLOTTING_BIN_ROOT}/epstopdf

if [ $# != 2 ]; then
    echo "Usage: $0 <x-axis-dir> <y-axis-dir>"
    exit 1
fi

xd=$1
yd=$2

# osmt2-master-results-2020-09-17-non-incremental-QF_UF
regex='osmt2-\(.*\)-results-\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)-\(.*\)-\([A-Z_]*\)'

x_branch=$(echo ${xd} |sed s/${regex}/\\1/g)
y_branch=$(echo ${yd} |sed s/${regex}/\\1/g)

x_date=$(echo ${xd} |sed s/${regex}/\\2/g)
y_date=$(echo ${yd} |sed s/${regex}/\\2/g)

x_track=$(echo ${xd} |sed s/${regex}/\\3/g)
y_track=$(echo ${yd} |sed s/${regex}/\\3/g)

x_div=$(echo ${xd} |sed s/${regex}/\\4/g)
y_div=$(echo ${yd} |sed s/${regex}/\\4/g)

if [ ${x_div} != ${y_div} ]; then
    echo "Division differ: ${x_div} != ${y_div}"
    exit 1;
fi

if [ ${x_track} != ${y_track} ]; then
    echo "Tracks differ: ${x_track} != ${y_track}"
    exit 1;
fi

echo "Extracting "
#${EXTRACTOR} ${xd} > ${xd}.list
#${EXTRACTOR} ${yd} > ${yd}.list
echo "done."


name=figures/${x_track}-${x_div}-${x_branch}-${x_date}_vs_${y_branch}-${y_date}

mkdir -p figures

echo "Plotting "
${GNUPLOTTOR} ${xd}.list ${yd}.list \
    "${x_branch} ${x_date}"\
    "${y_branch} ${y_date}" \
    ${name}.png > \
    ${name}.gp
echo "done."

echo "making "
make -f ${PLOT_MAKEFILE} ${name}.png
echo "done."