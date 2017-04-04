FROM ubuntu:16.04

#ssh
RUN apt-get update && apt-get install -y openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

#env - account: hadoop
ENV MY_HOME=/home/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle 
ENV	HADOOP_HOME=$MY_HOME/soft/apache/hadoop/hadoop-1.2.1
ENV	HADOOP_CONFIG_HOME=$HADOOP_HOME/conf
ENV	PATH=$PATH:$HADOOP_HOME/bin 
ENV	PATH=$PATH:$HADOOP_HOME/sbin 


#java
RUN apt-get -y install software-properties-common
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java8-installer && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk8-installer

#account
RUN adduser hadoop
RUN echo 'hadoop:m40931gf' | chpasswd
USER hadoop    

#hadoop
RUN mkdir -p $HOME/soft/apache/hadoop
WORKDIR $MY_HOME/soft/apache/hadoop
RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-1.2.1/hadoop-1.2.1.tar.gz
RUN tar xvzf hadoop-1.2.1.tar.gz

ADD core-site-org.xml $HADOOP_CONFIG_HOME
ADD hdfs-site-org.xml $HADOOP_CONFIG_HOME
ADD mapred-site-org.xml $HADOOP_CONFIG_HOME
#ADD masters-org $HADOOP_CONFIG_HOME
#ADD slaves-org $HADOOP_CONFIG_HOME

WORKDIR $HADOOP_CONFIG_HOME
RUN mv core-site.xml core-site-backup.xml
RUN mv hdfs-site.xml hdfs-site-backup.xml
RUN mv mapred-site.xml mapred-site-backup.xml
#RUN mv masters masters-backup
#RUN mv slaves slaves-backup
RUN mv core-site-org.xml core-site.xml
RUN mv hdfs-site-org.xml hdfs-site.xml
RUN mv mapred-site-org.xml mapred-site.xml
#RUN mv masters-org masters
#RUN mv slaves-org slaves

RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> hadoop-env.sh
RUN echo 'export HADOOP_HOME_WARN_SUPPRESS="TRUE"' >> hadoop-env.sh
RUN echo 'export HADOOP_PID_DIR=$HOME/soft/apache/hadoop/hadoop-1.2.1/pids' >> hadoop-env.sh

#etc
RUN mkdir -p $HOME/soft/apache/hadoop/hadoop-1.2.1/hadoop-data
RUN mkdir -p $HOME/soft/apache/hadoop/hadoop-1.2.1/pids

USER root  
CMD ["/usr/sbin/sshd", "-D"]













	


