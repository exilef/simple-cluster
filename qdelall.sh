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
# Delete all of our submitted/running jobs, or those with IDs above 
# the one passed as the first parameter $1
#
# This may need adjustment to the output of your qstat tool

MINID=0
if [ $# -gt 0 ]; then
	MINID=$1
fi

# first search for "job id" and "user" column in qstat output
header=$(qstat | head -n 1)
jobpos=1
userpos=4
curpos=1
for item in $header; do
	itemlow=$(echo $item | tr [:upper:] [:lower:])
	if [[ $itemlow = "job" || $itemlow = "job-id" ||  $itemlow = "job id" ]]; then
		jobpos=$curpos
	fi

	if [[ $itemlow = "user" || $itemlow = "owner" ]]; then
		userpos=$curpos
	fi

	curpos=$((curpos+1))
done


# now look for jobs belonging to current user and delete them
cuser=$(whoami)
while read job; do
	# set columns as arguments
	set -- $job

	if [[ $# -lt $jobpos || $# -lt $userpos ]]; then
		continue
	fi

	# get user and job id from arguments
	arguser=${!userpos}
	argjob=${!jobpos}

	if [[ ! $arguser =~ $cuser || $argjob -lt $MINID ]]; then
		# skip if not current user or job id smaller than MINID
		continue
	fi

	# delete job
	echo "qdel-ing $argjob"
	qdel "$argjob"

done < <(qstat)


# alternative version using grep and cut

#schedIds=$(qstat | grep `whoami` | cut -f 1 -d " ")
#for schedId in $schedIds; do
#	if [ $# -gt 0 ]; then
#		# we're only qdeling for sched id's above $1
#		if  [ $schedId -ge $1 ]; then
#			echo "qdel-ing $schedId"
#			qdel $schedId
#		else
#			echo "not qdel-ing $schedId"
#		fi
#	else
#		echo "qdel-ing $schedId"
#		qdel $schedId
#	fi
#done

