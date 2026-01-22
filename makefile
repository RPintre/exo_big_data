COMPOSE = docker-compose
PROJECT_NAME = Big_Data
.PHONY: all jupyter clean fclean re ref purge-volume purge-all re-purge-all
all:
	$(COMPOSE) up -d --build

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

purge-all:
	$(COMPOSE) down -v --rmi all
	
re-purge-all: purge-all all
