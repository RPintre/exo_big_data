COMPOSE = docker-compose
PROJECT_NAME = Big_Data
.PHONY: all jupyter kafka spark clean fclean re ref purge-volume purge-all re-purge-all
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
