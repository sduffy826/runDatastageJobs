#!/bin/bash
usage()
{
   echo "Script usage options.."
   echo "1) To check status of job just do"
   echo "   Usage: $0 <script_properties_file>"
   echo
}

checkfolder()
{
    # If folder does not exist or is not writable, print an error message and exit with given status
    exitstatus=$1
    folder=$2
    if [ ! -d "$folder" ]; then
      echo "ERROR: $folder cannot be found"
      exit $exitstatus
    elif [ ! -w "$folder" ]; then
      echo "ERROR: $folder does not have write permission"
      exit $exitstatus
    fi
}

sendmail()
{
    # If email id is not blank then send mail content to the recepient address
    email_id=$1
    subject=$2
    mailfile=$3
    if [ -n "$email_id" ]; then
        echo "Sending mail to $email_id"
        mail -s "$subject" "$email_id" < "$mailfile"
    fi
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

propertiesfile=`readlink -f "$1"`          # Absolute path to this file

if [ ! -f "$propertiesfile" ]; then
    usage
    exit 1
fi
source $propertiesfile

if [ ! -f "$dsengine_env" ]; then
    echo "The dsenv profile cannot be found. Please assign the correct path to 'dsengine_env' parameter in $propertiesfile file"
    exit 1
fi

if [ ! -n "$datastageproj" ]; then
    echo "Please assign the datastage project name to 'datastageproj' parameter in $propertiesfile file"
    exit 1
fi

if [ ! -n "$datastagejob" ]; then
    echo "Please assign the datastage job name to 'datastagejob' parameter in $propertiesfile file"
    exit 1
fi

if [ ! -n "$outputfolder" ]; then
    echo "Please specify folder name in 'outputfolder' parameter in $propertiesfile file for logging job run information"
    exit 1
fi

mkdir -p "$outputfolder"
checkfolder 1 $outputfolder

logfilename="dslastrun_`date "+%Y%m%d-%H.%M.%S"`.log"

source $dsengine_env

#Job Status      : RUNNING (0) ;* This is the only status that means the job is actually running
#Job Status      : RUN OK (1) ;* Job finished a normal run with no warnings
#Job Status      : RUN with WARNINGS (2) ;* Job finished a normal run with warnings
#Job Status      : RUN FAILED (3) ;* Job finished a normal run with a fatal error

echo "Checking status of previous execution for job $datastagejob" | tee "$outputfolder/$logfilename"
$DSHOME/bin/dsjob -jobinfo $datastageproj $datastagejob 
