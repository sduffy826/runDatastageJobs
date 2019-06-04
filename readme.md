This directory has files needed to build scripts to run the datastage jobs.

So the files here are really to build the script (and it's supporting properties) needed to run datastage jobs.
I did this cause I needed to perform the task repeatedly and doing it thru the user interface was taking
a while (and wasting my time watching a screen).  I have it were you can process one group of jobs or you can
use the 'makeAllJobs.sh' to create an exec that will run them all.
Read the scripts if you need more detail, should make sense.
===============================================================================================================
For the most part; there are two custom files for each job stream; they use other files but
most of the others are shared across jobs.

I'll use the 'Assets' job stream as an example.
First file: 'asset_vars.py' this contains the variable definitions; this is imported at runtime (will 
  make more sense later).  If you look at this file you'll see:
    jobs2Run - an array of the jobs to run for this stream (most have only one but some (like sap) have
               multiple jobs listed 
    stubFiles - these are the stub 'parameter' files used for the job; most have the 'global_stub.properties'
                and 'db_stub.properties' since they're common in many jobs.  The other one is usually 
                unique to this job
    script2Create - this is the name of the shell script that will be created (most vars file has
                    this as 'runDataStageJobs.sh').  Also note: there are property files that are
                    created, they have the name <jobs2Run>_program.properties

Second file: this is the 'unique stub properties file', for assets it's called: 'asset_stub.properties'
  the code reads the 'stub' files and creates an associated properties file for when the job is run.

General notes
- You don't want to 'polute' the directory where projects are run from, so I put all the files
    in a subdirectory off it, I used './runDSJobs'; you put everything in there and run the actual
    script to trigger the job from there also
- The default project is mine (sandbox-media3); if you want to change it you can use
    sed -i 's/sandbox-media3/projectName/g' *_vars.py  (I'd do this in a copy of the files in case
    things go wrong).
- The pw's for the connections are in the 'stub' files
- The repository used is in the '*_vars.py' files
- You may want to make 'stub'/'var' files for different connections/repo's, but I just used 'sed' to 
    make versions I wanted
- You don't want to have pw's in the files up in a public repo (git) so I created exec 'changePw.py', 
    run it like './changePw.py all set' to set the pw or './changePw.py all clear' to clear the pw.
    You can also run it for one file ('i.e. ./changePw.py asset set'), look at code for the names of
    the respective keys to use.


Test drive
- Pretend you want to create the shell/properties file so you can run 'sj_Assets' job; you'd do
     ./makeJob.sh asset_vars
  Note you don't suffix the file with .py
  When you execute this it'll create 'runDataStageJobs.sh' and 'sj_Assets_program.properties', if you
  want to run this job stream then just do './runDataStageJobs.sh'
- Pretend you want to change the project (to live) for the assets job, you might do:
  cp asset_vars.py asset_vars.py_backup # Make backup
  sed -i 's/sandbox-media3/live/g' asset_vars.py # Change inplace
- Pretend you want to create a script to run (almost) all the jobs, in the scheduled order
  Run './makeAllJobs.sh'  this will create a 'runDatastageJobs.sh', run it (and be patient... takes hours :))
  
