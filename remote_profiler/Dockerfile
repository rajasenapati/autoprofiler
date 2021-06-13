FROM ubuntu:latest
RUN apt-get update
RUN apt-get install wget -y
RUN apt-get install unzip -y
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install default-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir ~/apps
RUN wget https://mirrors.jevincanders.net/eclipse/mat/1.11.0/rcp/MemoryAnalyzer-1.11.0.20201202-linux.gtk.x86_64.zip -O ~/apps/mat.zip 
RUN cd ~/apps
RUN unzip ~/apps/mat.zip -d ~/apps
RUN mkdir ~/apps/mat/inbox
ADD run_mat.sh /root/apps/
ENTRYPOINT [ "/root/apps/run_mat.sh"] 
