DOCKER_COMPOSE := docker-compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml
DATA_DIR := $(HOME)/data
WP_DATA_DIR := $(DATA_DIR)/wordpress
DB_DATA_DIR := $(DATA_DIR)/mariadb

all: up

up: create_dirs
	@$(DOCKER_COMPOSE) up --build -d

down:
	@$(DOCKER_COMPOSE) down -v

re:	down fclean up

clean:
	@(docker system prune -af --volumes)
	@(docker volume prune -f)
	@(docker network prune -f)

fclean: clean
	@$(DOCKER_COMPOSE) down --rmi all --volumes --remove-orphans
	@if [ -n "$$(docker ps -aq)" ]; then docker rm -f $$(docker ps -aq); fi
	@if [ -n "$$(docker images -q)" ]; then docker rmi -f $$(docker images -aq); fi
	@sudo rm -rf $(WP_DATA_DIR)
	@sudo rm -rf $(DB_DATA_DIR)

create_dirs:
	@if [ ! -d "$(DATA_DIR)" ]; then \
		mkdir -p $(DATA_DIR); \
	fi
	@mkdir -p $(WP_DATA_DIR)
	@mkdir -p $(DB_DATA_DIR)

.PHONY: all up down re clean fclean
