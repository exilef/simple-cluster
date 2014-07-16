#!/bin/bash
#
# Simpler Cluster Framework
# Copyright (C) 2013, F. Effenberger. effenberger.felix@gmail.com
#
# Simple cluster jobs framework
# Copyright (C) 2011, J. Lizier. joseph.lizier@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ---------------------------------------------------------------------
#
# Script that submits a single job
#
# Arguments: <JOBTEMPLATE> <PROPSTEMPLATE or - > [ <P1> <P2> <P3> ... ]"
#
# Where JOBTEMPLATE specified template file for job to be created,
# PROPSTEMPLATE the (optional) template file of the props file to be
# used and P1 to Pn the parameter values of [@P1] to [@Pn]
# If no template for the properties file is to be used, pass "-" as
# second argument

runId=$(date +%F-%H-%M-%S-%N)

scriptPath=run/scripts
scriptPathEsc=run\\/scripts
propsPath=run/props
propsPathEsc=run\\/props
logPath=run/log
logPathEsc=run\\/log

function usage {
        echo "usage: $0 <JOBTEMPLATE> < PROPSTEMPLATE or - > [ <P1> <P2> <P3> ... ]"
        exit 1
}

echo "preparing single job"

if [[ $# -lt 2 ]]; then
	usage
fi

jobtempl=$1
shift

if [[ ! -e "$jobtempl" ]]; then
	echo "job file template '$jobtempl' not found, aborting!"
	exit 1
fi

propstempl=$1
shift

if [[ "$propstempl"=="-" ]]; then
	echo "not using properties file"
else
	echo "using properties file"
	if [ ! -e $propstempl ]; then
		echo "properties file template '$propstempl' not found, aborting!"
		exit 1
	fi
	
	cp "$propstempl" "$propsPath/props.tmp"
fi

# parameter substitution
parmidx=1
cp "$jobtempl" "$scriptPath/script.tmp"
prefix=""
parms=( )
while [ $# -gt 0 ]; do
	sed -i -e "s:\[@P$parmidx\]:$1:g" "$scriptPath/script.tmp"
	if [[ ! "$propstempl"=="-" ]]; then
		sed -i -e "s:\[@P$parmidx\]:$1:g" "$propsPath/props.tmp"
	fi
	prefix="${prefix}-$(echo $1 | tr ' ' '_' | sed -e s/[^\]\[A-Za-z0-9~.,_{}\(\)\'\-\+]//g)"
	parms=( "${parms[@]}" "$1" )
	shift
	parmidx=$((parmidx+1))
done

sed -i -e "s:\[@P[0-9]*\]:NA:g" "$scriptPath/script.tmp"

if [[ ! "$propstempl"=="-" ]]; then
	sed -i -e "s:\[@P[0-9]*\]:NA:g" "$propsPath/props.tmp"
fi

echo "running job with parameters: ${parms[*]}"

# generate final filenames
scriptfile="job$prefix.$runId.sh"
propsfile="job$prefix.$runId.properties"
logfile="job$prefix.$runId.log"
errfile="job$prefix.$runId.err"

echo "job files:"
echo "sh    file -> $scriptPath/$scriptfile"

if [[ "$propstempl"=="-" ]]; then
	echo "props file -> none"
else
	echo "props file -> $propsPath/$propsfile"
fi

echo "log   file -> $logPath/$logfile"
echo "err   file -> $logPath/$errfile"

mv "$scriptPath/script.tmp" "$scriptPath/$scriptfile"

if [[ ! "$propstempl"=="-" ]]; then
	mv "$propsPath/props.tmp" "$propsPath/$propsfile"
fi

# parameter substitution in script file
CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
prefix="$prefix.$runId"
sed -i -e "s:\[@LOGFILE\]:$logPath/$logfile:g" -e "s:\[@ERRFILE\]:$logPath/$errfile:g" -e "s:\[@PROPSFILE\]:$propsPath/$propsfile:g" -e "s:\[@LOGFILEESC\]:$logPathEsc/$logfile:g" -e "s:\[@ERRFILEESC\]:$logPathEsc/$errfile:g" -e "s:\[@PROPSFILEESC\]:$propsPathEsc/$propsfile:g" -e "s:\[@JOBSCRIPT\]:$scriptPath/$scriptfile:g" -e "s:\[@BASEPATH\]:$CURDIR:g" -e "s:\[@JOBPREFIX\]:$prefix:g"  $scriptPath/$scriptfile

chmod u+x "$scriptPath/$scriptfile"

# Submit the job:
echo "submitting process..."
qsub "$scriptPath/$scriptfile"
exit $?
