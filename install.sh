#!/bin/bash
#
# Simpler Cluster Framework
# Copyright (C) 2013, F. Effenberger. effenberger.felix@gmail.com
#
# Based on Simple Cluster Framework
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
# Install script for Simpler Cluster Framework,
# creates needed working directories

echo "Simpler Cluster Framework install script"

dirs=(bin dat_in dat_out run run/scripts run/props run/log)

for d in "${dirs[@]}"
do
	echo "Creating directory $d if non-existent"
	[[ ! -e $d ]] && mkdir -p $d
done

echo "All done"
