DOCKER_COMPOSE := docker-compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml

all: up

up:
	@$(DOCKER_COMPOSE) up --build -d

down:
	@$(DOCKER_COMPOSE) down

re:	down fclean up

clean:
	@(docker system prune -af --volumes)
	@(docker volume prune -f)
	@(docker network prune -f)

fclean: clean
	@if [ -n "$$(docker images -q)" ]; then docker rmi -f $$(docker images -aq); fi

.PHONY: all up down re clean fclean
