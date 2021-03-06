docker rm -f master
docker rm -f slave1
docker rm -f slave2

#network
docker network rm mynet
docker network create --subnet=172.19.0.0/16 mynet

docker run -it --net mynet -h master --ip 172.19.0.2 -p 8081:50070 \
	--add-host slave1:172.19.0.3 \
	--add-host slave2:172.19.0.4 \
	-d --name master namenode:1.0 
docker run -it --net mynet -h slave1 --ip 172.19.0.3 \
	--add-host master:172.19.0.2 \
	--add-host slave2:172.19.0.4 \
	-d --name slave1 datanode:1.0
docker run -it --net mynet -h slave2 --ip 172.19.0.4 \
	--add-host master:172.19.0.2 \
	--add-host slave1:172.19.0.3 \
	-d --name slave2 datanode:1.0

#masters
mkdir tmpMasters
touch tmpMasters/masters

echo slave1 >> tmpMasters/masters

docker exec -i master sh -c 'cat > $HADOOP_CONFIG_HOME/masters' < tmpMasters/masters

rm -r tmpMasters

#slaves
mkdir tmpSlaves
touch tmpSlaves/slaves

echo slave1 >> tmpSlaves/slaves
echo slave2 >> tmpSlaves/slaves

docker exec -i master sh -c 'cat > $HADOOP_CONFIG_HOME/slaves' < tmpSlaves/slaves

rm -r tmpSlaves	

#ssh without a prompt
docker exec -it master ssh-keygen -t rsa -q -f "/root/.ssh/id_rsa" -N ""
docker exec -it slave1 ssh-keygen -t rsa -q -f "/root/.ssh/id_rsa" -N ""
docker exec -it slave2 ssh-keygen -t rsa -q -f "/root/.ssh/id_rsa" -N ""
docker exec -it master ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@master
docker exec -it master ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@slave1
docker exec -it master ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@slave2

#deploy a hadoop jar to datanode
docker exec -it master sh -c 'tar -C $HADOOP_HOME/.. -zcvf $HADOOP_HOME/../hadoop-1.2.1-1.0.tar.gz hadoop-1.2.1'
docker exec -it master sh -c 'scp $HADOOP_HOME/../hadoop-1.2.1-1.0.tar.gz root@slave1:/home/hadoop/soft/apache/hadoop/'
docker exec -it master sh -c 'scp $HADOOP_HOME/../hadoop-1.2.1-1.0.tar.gz root@slave2:/home/hadoop/soft/apache/hadoop/'
docker exec -it slave1 sh -c 'tar -zxvf /home/hadoop/soft/apache/hadoop/hadoop-1.2.1-1.0.tar.gz'
docker exec -it slave2 sh -c 'tar -zxvf /home/hadoop/soft/apache/hadoop/hadoop-1.2.1-1.0.tar.gz'

#hadoop start
#docker exec -it master sh -c '$HADOOP_HOME/bin/stop-all.sh';
docker exec -it --user hadoop master sh -c '$HADOOP_HOME/bin/hadoop namenode -format';
docker exec -it --user hadoop master sh -c '$HADOOP_HOME/bin/start-all.sh';
#docker exec -it master /bin/bash





