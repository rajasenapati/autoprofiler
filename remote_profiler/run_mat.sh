#!/bin/bash

#USAGE:
#  run_mat.sh maxHeapMemory heapDumpFileName
#  example:
#  run_mat.sh -Xmx2048m ubuntu_java_pid3037534.hprof
#        maxHeapMemory = max heap memory to allocate to the profiler while doing the analysis. In the above example, -Xmx2048m allocates 2GB of heap memory to the remote profiler
#        heapDumpFileName = name of the heap dump hprof file which will be analyzed by the profiler. In the above example, ubuntu_java_pid3037534.hprof is the heap dump file to be analyzed
  
hprof_file="/root/apps/mat/inbox/${2}"
MAT_CMD="/root/apps/mat/MemoryAnalyzer -consolelog -application"
PARSE=org.eclipse.mat.api.parse
SUSPECT_REPORT=org.eclipse.mat.api:suspects
OVERVIEW_REPORT=org.eclipse.mat.api:overview
COMPONENT_REPORT=org.eclipse.mat.api:top_components
VMARGS="-vmargs ${1:--Xmx1024m} -XX:-UseGCOverheadLimit -Djava.awt.headless=true"
if [ -f "$hprof_file" ]
then
    echo "processing $hprof_file"
    $MAT_CMD $PARSE $hprof_file $SUSPECT_REPORT $OVERVIEW_REPORT $COMPONENT_REPORT $VMARGS
    echo "processed $hprof_file"
    rm $hprof_file
    echo "removed $hprof_file"
fi
