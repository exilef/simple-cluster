#!/bin/bash
#
# Simpler Cluster Framework
# Copyright (C) 2013, F. Effenberger. effenberger.felix@gmail.com
#
# Simple cluster jobs framework
# Copyright (C) 2011, J. Lizier. joseph.lizier@gmail.com
#
# Additions and modifications F. Effenberger, 2012
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
# Script to submit several processes with an arbitray number of
# parameters updated in the input file for each run.
#
# Arguments: <JOBTEMPL> <<PROPSTEMPL> or - > <E1> [ <E2> <E3> ... ],
#
# Where JOBTEMPLATE specifies the template file for job to be created,
# PROPSTEMPLATE the (optional) template file of the properties file to
# be used and and En=<START INCREMENT STOP> or En=<VALUE ->"
#
# If no template for the properties file is to be used, pass "-" as
# second argument
#
# Any number of tuples En of the form <VALUE -> or
# <START INCREMENT STOP> can be supplied,  where a tuple of the form
# <VALUE -> specifies a fixed input parameter  and a tuple of the form
# <START INCREMENT STOP> a range of integer numbers.
# These are mapped to the arguments [@P1] to [@Pn]
#
# Example ./runmany.sh templates/jobtemplate.sh 
#                      templates/proptemplate.sh 
#                      "astring" - 0 2 10 -5 1 5
#
# Runs jobs specified in templates/jobtemplate.sh with parameter
# template file templates/proptemplate.sh in which the parameters [@Pn]
# are subsituted:
#
# [@P1] is set to "astring"
# [@P2] ranges from 0 to 10 in steps of 2
# [@P3] ranges from -5 to 5 in steps of 1
# 
# This would create  1 * 6 * 11 = 66 jobs

argmin=( )
arginc=( )
argmax=( )
vec=( )

function usage {
        echo "usage: $0 <JOBTEMPL> <<PROPSTEMPL> or - > <E1> [ <E2> <E3> ... ], where En=<START INCREMENT STOP> or En=<VALUE ->"
        exit 1
}

if [[ $# -le 2 ]]; then
	usage
fi

jobtempl=$1
shift

if [[ ! -e "$jobtempl" ]]; then
	echo "job file template '$jobtempl' not found, aborting!"
	exit 1
fi

echo "job file template: '$jobtempl'."


propstempl=$1
shift

if [[ "$propstempl"=="-" ]]; then
	echo "not using properties file"
else

	if [[ ! -e "$propstempl" ]]; then
		echo "properties file template '$propstempl' not found, aborting!"
		exit 1
	fi

	echo "properties file template: '$propstempl'."
fi

# extract parameters passed to scripts
echo "chosen parameters:"
pos=0
numjobs=1
while [[ $# -gt 0 ]]; do
	argmin[$pos]=$1
	vec[$pos]=$1

	shift
	if [[ $# -lt 1 ]]; then
		usage
	fi

	if [[ $1 = "-" ]]; then
		rpos=$((pos+1))
		echo "parameter $rpos -> ${argmin[$pos]} (constant)"
		arginc[$pos]=0
		argmax[$pos]=0
		pos=$((pos+1))
		shift
		continue
	fi

	arginc[$pos]=$1

	if [[ $1 -lt 1 ]]; then
		echo "increment must be postitive for parameter $pos."
		exit 1
	fi

	shift
	if [[ $# -lt 1 ]]; then
		usage
	fi

	argmax[$pos]=$1

	if [[ $1 -lt ${argmin[$pos]} ]]; then
		echo "maximum must be larger or equal to minimum for parameter $pos."
		exit 1
	fi

	numjobs=$((numjobs*((${argmax[$pos]}-${argmin[$pos]})/${arginc[$pos]}+1)))

	rpos=$((pos+1))
	echo "parameter $rpos -> ${argmin[$pos]}..${argmax[$pos]}, step ${arginc[$pos]}"
	shift
	pos=$((pos+1))
done

if [[ $numjobs -lt 0 ]]; then
	numjobs=$((-numjobs))
fi

echo ""
read -p "will submit $numjobs job(s), continue with submission? [Y/n]" -r
if [[ ! ( $REPLY =~ [Yy]$ || $REPLY == "" ) ]]; then
	echo "submission cancelled, exiting."
	exit 0
fi


echo "processing $pos parameters"
echo ""

# work whole list
posmax=$((pos-1))
pos=$posmax
while true; do
	while [[ ${vec[$pos]} -le ${argmax[$pos]} ]]; do
		./runone.sh "$jobtempl" "$propstempl" ${vec[@]}

		if [[ $? -ne 0 ]]; then
			echo "error submitting job, please check your settings/templates/parameters. aborting."
			exit 1
		fi
	
		if [[ ${arginc[$pos]} -eq 0 ]]; then
			break
		fi

		vec[$pos]=$((vec[$pos]+arginc[$pos]))
		echo ""
	done
	

	# step back
	while [[ ${arginc[$pos]} -eq 0 || ${vec[$pos]} -gt ${argmax[$pos]} ]]; do
		vec[$pos]=${argmin[$pos]} #reset current
		pos=$((pos-1))

		if [[ $pos -lt 0 ]]; then
			echo "all done."
			exit 0
		fi

		if [[ ${arginc[$pos]} -gt 0 ]]; then
			vec[$pos]=$((vec[$pos]+arginc[$pos])) #increment parent
		fi
	done

	pos=$posmax
done

echo ""
echo "all jobs submitted."

