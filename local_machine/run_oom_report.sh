#!/bin/bash

#USAGE:
#  run_oom_report.sh localHprofFileLocation maxHeapMemory userID@hostOfTheRemoteProfiler sshIdentityFileToConnectToRemoteHostInKeylessMode
#  example:
#  run_oom_report.sh /tmp/ -Xmx2048m alex@remoteProfiler /home/alex/.ssh/googlecompute
#        localHprofFileLocation = location where the hprof files are dumped locally when OOM is triggered. In the above example, hprof files are generated in /tmp/ folder 
#        maxHeapMemory = max heap memory to allocate to the profiler while doing the analysis. In the above example, -Xmx2048m allocates 2GB of heap memory to the remote profiler
#        userID@hostOfTheRemoteProfiler = user/host information of the remote profiler. In the above example, alex@remoteProfiler indicates we use alex user's credential to connect to remoteProfiler host
#        sshIdentityFileToConnectToRemoteHostInKeylessMode = identity file to connect to the remote host in ssh keyless mode. In the above example, we use /home/alex/.ssh/googlecompute as the identity file

#This is the local directory where hprof files are generated and stored. This can be passed as the first parameter to the script. Default is /tmp
HPROF_FILES=${1:-/tmp}

#hostname will be used later to namespace the heapdump files. This will enable the remote profiler to run multiple heapdumps for different clients
HOSTNAME=`hostname`

#Remote profiler which hosts the MAT docker. The local host has keyless ssh access on this machine
REMOTE_MACHINE=${3}

#remote directory of the Remote Profiler where the local heapdump files will be copied
REMOTE_DESTINATION=/tmp

#Idenitity file to be used for keyless ssh based access. If the keyless entry is set to default .ssh file, set this to empty
IDENTITY_FILE_CMD="-i ${4}"

#maximum JVM heap allocation as passed from script's second command line parameter. default is 1GB. 
VM_MAX_MEMORY=${2:--Xmx1024m}

#process all hprof files from HPROF_FILES location
for hprof_file in `ls ${HPROF_FILES}/*.hprof`
do
     if [ -f "$hprof_file" ]
     then
         #namespace the hprof file with hostname to support simultaneous profiling from multiple hosts
         BASE_TARGET_FILE_NAME=${HOSTNAME}_$(basename ${hprof_file})

         #change the extension to filename.hprof.processing to indicate the file is currently being processed 
         PROCESSING_FILE_NAME="${hprof_file}.processing"

         #change the extension to filename.hprof.processed to indicate the file has been processed
         PROCESSED_FILE_NAME="${hprof_file}.processed"
         
         #add .processing extension to the hprof file currently being processed
         mv $hprof_file $PROCESSING_FILE_NAME
         if [ -f "$PROCESSING_FILE_NAME" ]
         then
            #copy the currently processing file to remote profiler as a hprof file with namespace
            echo "uploading $PROCESSING_FILE_NAME as ${REMOTE_DESTINATION}/${BASE_TARGET_FILE_NAME}"
            scp $IDENTITY_FILE_CMD $PROCESSING_FILE_NAME ${REMOTE_MACHINE}:${REMOTE_DESTINATION}/${BASE_TARGET_FILE_NAME}
            echo "copied $PROCESSING_FILE_NAME as ${REMOTE_DESTINATION}/${BASE_TARGET_FILE_NAME}"

            #trigger the remote profiler
            echo "Now trigger the Remote Profiler - ssh $IDENTITY_FILE_CMD ${REMOTE_MACHINE} docker run -v ${REMOTE_DESTINATION}:/root/apps/mat/inbox  mat-image $VM_MAX_MEMORY ${BASE_TARGET_FILE_NAME}"
            ssh $IDENTITY_FILE_CMD ${REMOTE_MACHINE} docker run -v ${REMOTE_DESTINATION}:/root/apps/mat/inbox  mat-image $VM_MAX_MEMORY ${BASE_TARGET_FILE_NAME}
            
            #now collect the reports from the remote profiler
            CHECK_PREFIX="${BASE_TARGET_FILE_NAME/.hprof/\*.zip}"
            echo "Now collect the reports - scp $IDENTITY_FILE_CMD ${REMOTE_MACHINE}:${REMOTE_DESTINATION}/${CHECK_PREFIX} /tmp"
            scp $IDENTITY_FILE_CMD ${REMOTE_MACHINE}:${REMOTE_DESTINATION}/${CHECK_PREFIX} /tmp
            
            #mark the file as processed
            mv $PROCESSING_FILE_NAME $PROCESSED_FILE_NAME
         fi
     fi
done

