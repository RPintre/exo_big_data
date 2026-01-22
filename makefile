COMPOSE = docker-compose
PROJECT_NAME = Big_Data
.PHONY: all clean fclean ref re purge-bdd re-purge-all purge-all kafka jupyter
all:
	$(COMPOSE) up -d --build
kafka:
	$(COMPOSE) down -v kafka
	docker image rm apache/kafka:latest
	$(COMPOSE) up -d --build kafka

jupyter:
	$(COMPOSE) down -v jupyter
	docker image rm jupyter/pyspark-notebook:spark-3.4.1
	$(COMPOSE) up -d --build jupyter

clean:
	$(COMPOSE) down

fclean: clean
	docker image prune -a -f

re: clean all

ref: fclean all

purge-bdd: clean
	docker volume rm namenode
	docker volume rm datanode

purge-all:
	$(COMPOSE) down -v --rmi all
	
re-purge-all: purge-all all
