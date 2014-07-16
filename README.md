simpler-cluster
===============

Convenience framework for working with clusters managed
with the Sun Grid Engine, i.e. for which jobs are managed by the tools
qsub and qstat.

Based upon [Simple cluster jobs framework](http://lizier.me/joseph/software/simplecluster/)
by J. Lizier, modified to only use bash and not to depend on ksh.
Additionally provides more flexible parameter expansion.

This framework uses Java-style properties files for passing parameters
to the batch scripts.

For each job to be submitted, two files are created: one shell file that
is executed by the grid engine and one parameter file that is used to
pass parameters to the job.

Installation
------------

Download or clone repository and run `./install.sh` to create the
working directories.


Usage
-----

See also the documentation of [Simple cluster jobs framework](http://lizier.me/joseph/software/simplecluster/).

A typical usage scenario is the following:

1. Create job templates file and parameter template file for batch job
   to be run. For this just make a copy of the files in the `templates/`
   folder. Adjust settings and parameters as needed.
   
2. Manage jobs with the scripts `runone.sh`, `runmany.sh`, `qdelall.sh`,
   `restartfailed.sh` and `cleanup.sh`. Descriptions below.
   
### runone.sh

Submits a single job.

Arguments: `<JOBTEMPLATE> <PROPSTEMPLATE or - > [ <P1> <P2> <P3> ... ]"`

Where JOBTEMPLATE specified template file for job to be created,
PROPSTEMPLATE the (optional) template file of the props file to be
used and P1 to Pn the parameter values of `[@P1]` to `[@Pn]`
If no template for the properties file is to be used, pass "-" as
second argument

### runmany.sh

Submits several processes with an arbitray number of
parameters updated in the input file for each run.

Arguments: `<JOBTEMPL> <PROPSTEMPL or - > <E1> [ <E2> <E3> ... ]`,

Where JOBTEMPLATE specifies the template file for job to be created,
PROPSTEMPLATE the (optional) template file of the properties file to
be used and and En=<START INCREMENT STOP> or En=<VALUE ->"

If no template for the properties file is to be used, pass "-" as
second argument

Any number of tuples En of the form `<VALUE ->` or
`<START INCREMENT STOP>` can be supplied,  where a tuple of the form
`<VALUE ->` specifies a fixed input parameter  and a tuple of the form
`<START INCREMENT STOP>` a range of integer numbers.
These are mapped to the arguments `[@P1]` to `[@Pn]`

Example `./runmany.sh templates/jobtemplate.sh 
                     templates/proptemplate.sh 
                     "astring" - 0 2 10 -5 1 5`

Runs jobs specified in templates/jobtemplate.sh with parameter
template file templates/proptemplate.sh in which the parameters `[@Pn]`
are subsituted:

`[@P1] is set to "astring"`

`[@P2] ranges from 0 to 10 in steps of 2`

`[@P3] ranges from -5 to 5 in steps of 1`
 
This would create  1 * 6 * 11 = 66 jobs

### qdelall.sh

Deletes all of our submitted/running jobs, or those with IDs above 
the one passed as the first parameter if it is provided.

This may need adjustment to the output of your qstat tool.

### restartfailed.sh

Tries to restart all of your failed jobs logged in the file 
run/JOBSFAILED

### cleanup.sh

Cleans up all of the job files created. Does not touch files
outside of the directory `run/`


LICENSE
-------

GPLv3
