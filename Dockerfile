FROM ubuntu:20.04
FROM python:3.8

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget && apt install -y python3-pip

# install hadoop 3.2.3
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.2.3/hadoop-3.2.3.tar.gz && \
    tar -xvf hadoop-3.2.3.tar.gz && \
    mkdir /opt && \
    mv hadoop-3.2.3/ /opt && \
    mv hadoop-3.2.3/ hadoop && \
    wget https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz && \
    tar -xvf spark-3.2.1-bin-hadoop3.2.tgz && \
    mv spark-3.2.1-bin-hadoop3.2/ /opt/hadoop && \
    mv spark-3.2.1-bin-hadoop3.2/ /opt/hadoop/spark && \
    wget http://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    tar -xvf sqoop-1.4.7.bin__hadoop-2.6.0 && \
    mv sqoop-1.4.7.bin__hadoop-2.6.0/ /opt/hadoop && \
    mv sqoop-1.4.7.bin__hadoop-2.6.0/ /opt/hadoop/spark && \

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV HADOOP_YARN_HOME=$HADOOP_HOME
ENV SQOOP_HOME=/opt/hadoop/sqoop
ENV HIVE_HOME=/opt/hadoop/hive
ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:/opt/hadoop/spark/bin:/opt/hadoop/spark/sbin:$SQOOP_HOME/bin:$HIVE_HOME/bin
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV SPARK_DIST_CLASSPATH=$(hadoop classpath)


# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p /datos/namenode && \ 
    mkdir -p /datos/datanode && \
    mkdir $HADOOP_HOME/logs

RUN hdfs dfs -mkdir /desarrollo/
RUN hdfs dfs -mkdir /MiddleProcess/

COPY config/* /tmp/
COPY Preprocesado/* ~
WORKDIR /Preprocesado
RUN pip install -r requirements.txt

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /opt/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh

# format namenode
RUN /opt/hadoop/bin/hdfs namenode -format

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

CMD ["sh", "-c", "service ssh start; bash"]
