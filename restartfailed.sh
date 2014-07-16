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
# Tries to restart all of your failed jobs logged in the file 
# run/JOBSFAILED

echo "checking for failed jobs.."

if [ ! -e "run/JOBSFAILED" ]; then
	echo "file ./run/JOBSFAILED does not exist, cannot continue (probably there are no failed jobs?)."
	exit 1
fi

numjobs=$(cat "run/JOBSFAILED" | wc -l)

if [[ $numjobs -lt 1 ]]; then
	echo "no failed jobs, exiting."
	exit 0
fi

read -p "will re-submit $numjobs failed job(s), continue with submission? [Y/n]" -r
if [[ ! ( $REPLY =~ [Yy]$ || $REPLY == "" ) ]]; then
	echo "submission cancelled, exiting."
	exit 0
fi

while read line; do
	echo "resubmitting job $line"
	qsub "$line"
	echo ""
done < "run/JOBSFAILED"

echo "all done"

