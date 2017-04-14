IMAGE := mongrelion/blog
TAG   := 2.0.0
NAME  := $(IMAGE):$(TAG)

site:
	@echo "-> building site with Hugo"
	@docker run                \
		--rm                     \
		-it                      \
		-v $$PWD:/usr/share/hugo \
		mongrelion/hugo:0.20.1

image:
	@echo "-> building container image $(NAME)"
	@docker build \
		-t $(NAME)  \
		.

push:
	@echo "-> pusing container image $(NAME) to DockerHUB"
	@docker push $(NAME)

login:
	@echo "-> logging into DockerHUB"
	@docker login -u=$(DOCKER_USER) -p=$(DOCKER_PASS)

test:
	@docker run --rm -it -p 80:80 $(NAME)
