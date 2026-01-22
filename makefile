COMPOSE = docker-compose
PROJECT_NAME = Big_Data
.PHONY: all jupyter kafka spark hdfs hdfs-up clean fclean re ref purge-volume purge-all re-purge-all
all:
	$(COMPOSE) up -d --build

jupyter:
	$(COMPOSE) down -v jupyter
	docker image rm jupyter/pyspark-notebook:spark-3.4.1
	$(COMPOSE) up -d --build jupyter

kafka:
	$(COMPOSE) down -v kafka
	docker image rm apache/kafka:latest
	$(COMPOSE) up -d --build kafka

spark:
	$(COMPOSE) down -v spark
	$(COMPOSE) down -v spark-worker
	docker image rm spark:latest
	$(COMPOSE) up -d --build spark
	$(COMPOSE) up -d --build spark-worker


hdfs:
	$(COMPOSE) down -v namenode datanode
	docker image rm bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8
	docker image rm bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8
	$(MAKE) hdfs-up

hdfs-up:
	$(COMPOSE) up -d --build namenode
	$(COMPOSE) up -d --build datanode

clean:
	$(COMPOSE) down

fclean: clean
	docker image prune -a -f

re: clean all

ref: fclean all

purge-volume: clean
	docker volume rm kafkaData
	docker volume rm kafkaSecrets
	docker volume rm kafkaConfig

purge-all:
	$(COMPOSE) down -v --rmi all
	
re-purge-all: purge-all all
