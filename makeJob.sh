#!/usr/bin/python

import os
import sys
import time

# --------------------------------------------------------------------------------------------------------------
# NOTE: Put up here so you see... you don't need to move the resulting exec or files anywhere it is expected to
#       be run from the directory you are in.  Intentionally done so you don't pollute the projects directory
#       with a bunch of files.  disclaimer: you can move the files, but I wouldn't :)
#
# This program creates an exec (and required files) used to run datastage jobs.  You should pass it the
#   name of the python file that has the variables that define the:
#   datastageproj --- The datastage to project to run from
#   jobs2Run -------- Array that has the jobs (usually sequence) jobs to be run
#   stubFiles ------- An array that has the 'stub' property files needed for the job; these are the parameters
#                       to the job... many are common across different jobs.  List the ones you need an they'll
#                       be combined here
#   script2Create --- The shell script that this program will create
# To give an example take a look at the 'assets_var.py' file you'll see the variables above defined; you
#   would invoke this program like 'makeJob.sh assets_var' it will create the appropriate shell script
#   (probably runDatastageJobs.sh) and also the corresponding property files for 'jobs2Run' (probably
#   sj_Assets_program.properties).
# Optional parms:
#   append - means you want to append to the file referenced in 'script2Create' (really only applicable if the
#              vars file references same one).
# --------------------------------------------------------------------------------------------------------------
appendMode = False
runMode    = False
if (len(sys.argv) < 2):
  print("You should pass in the type of file to process")
  quit()
for theArgs in sys.argv:
  if (theArgs == "append"):
    appendMode = True
  elif (theArgs == "runAfter"):
    runMode = True

if (appendMode == False):
  print("If you need to set/clear pw (changePw.py) hit ctrl+break now")
  print("  (you have 3 seconds)")
  time.sleep(3)

# import the variable definitions and set the variables here
impFile = __import__(sys.argv[1])

datastageproj = impFile.datastageproj  # "sandbox-media3"
jobs2Run      = impFile.jobs2Run       # ["sj_Assets"]
stubFiles     = impFile.stubFiles      # ["assets_stub.properties","global_stub.properties","db_stub.properties"]
script2Create = impFile.script2Create  # "runDatastageJobs.sh"

# Remove the file passed in if it exists
def deleteIfFileExists(file2Check):
  if os.path.exists(file2Check):
    os.remove(file2Check)

# Add job to script 
def addJobToScript(scriptFileHandle, jobProperties):
  scriptFileHandle.write('echo "Time: $(date)   directoryName:$directoryName  currentDirectory:$PWD"\n')
  scriptFileHandle.write("bash ./execute_dstagejob.sh -start $directoryName/" + jobProperties + "\n")
  scriptFileHandle.write("exitRC=$?\n")
  scriptFileHandle.write('echo "' + jobProperties + ' $exitRC"\n')
  scriptFileHandle.write("if [[ $exitRC -gt 2 ]]; then exit $exitRC; fi\n")

# split parm into name/value pairs
def splitParm(string2Split):
  nameValue = ["",""]
  firstPass = string2Split.split("=")
  if (len(firstPass) == 2):
    nameValue[0] = firstPass[0].strip()  # name
    nameValue[1] = firstPass[1].strip()  # value
  return nameValue

# Start of work

# If append mode then check if file exists, if not turn off appendMode
if (appendMode == True):
  if (os.path.exists(script2Create) == False):
    appendMode = False

# If not in appendMode then delete file (if it exists)
if (appendMode == False):
  deleteIfFileExists(script2Create)

scriptHandle = open(script2Create,"a")  # Append (will create if file doesn't exist)

if (appendMode == False):
  scriptHandle.write("#!/bin/bash\n")
  scriptHandle.write("directoryName=`dirname $(readlink -f $0)`\n")

scriptHandle.write("# Go to project directory\n")
scriptHandle.write("cd /opt/IBM/InformationServer/Server/Projects/" + datastageproj + "\n")
scriptHandle.write("# Execute script and specify properties file to use\n")

for aJob in jobs2Run:
  print("Job: " + aJob)

  # Create properties file for the job
  outputFile = aJob + "_program.properties"
  deleteIfFileExists(outputFile)
  fileHandle = open(outputFile,"w")

  fileHandle.write("datastageproj=" + datastageproj + "\n")
  fileHandle.write("datastagejob=" + aJob + "\n")
  fileHandle.write("dsengine_env=/opt/IBM/InformationServer/Server/DSEngine/dsenv\n")
  fileHandle.write("outputfolder=/tmp\n")
  fileHandle.write("email=\n")

  # Array to hold properties
  propBody = []

  # We append the lines from the stubFiles to the properties file
  parmCnt = 0
  for file2Read in stubFiles:
    file2ReadHandle = open(file2Read)
    # loop thru the lines, each is in format paramName = paramValue so split
    #   them and write them to the file
    for aLine in file2ReadHandle:
      rtnValues = splitParm(aLine)
      if (len(rtnValues[0]) > 0):
        parmCnt = parmCnt + 1
        propBody.append("param" + str(parmCnt) + "=" + rtnValues[0] + "\n")       
        propBody.append("valueforparam" + str(parmCnt) + "=" + rtnValues[1] + "\n")
    file2ReadHandle.close()

  # Write out parameter count, then parms
  fileHandle.write("paramcount=" + str(parmCnt) + "\n")
  for parmData in propBody:
    fileHandle.write(parmData)

  fileHandle.close()

  # Add this to the script
  addJobToScript(scriptHandle,outputFile)

# Return to directory
scriptHandle.write("cd $directoryName\n")

# All done, close script
scriptHandle.close()

pathAndName = "./"+script2Create
print("Executable script is: " + pathAndName)
os.chmod(pathAndName,0754)
