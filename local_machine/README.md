**Usage Instruction**
copy all the files into a folder, lets say $APP. Inside the $APP folder, do following:
1. compile the sample app `javac SampleMemoryLeaker.java`
2. run the sample app in a memory constrained mode to trigger OOM, followed by profiler call
```
java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath="/tmp/" -XX:OnOutOfMemoryError="$APP/run_oom_report.sh /tmp/ -Xmx2048m $USER@$HOST $PATH_TO_IDENTITY_FILE"  -Xmx4m SampleMemoryLeaker

```

3. The OOM event will trigger a call to the remote profiler, uploading the heapdump file. 
4. The remote profiler anayzes the heap dump file and generates zipped reports. 
5. The reports are downloaded to /tmp folder. 