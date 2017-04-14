IMAGE  := mongrelion/blog
TAG    := 2.1.1
NAME   := $(IMAGE):$(TAG)
LATEST := $(IMAGE):latest

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
	@echo "-> pusing container image $(NAME) to dockerhub"
	@docker push $(NAME)

latest:
	@echo "-> aliasing container image $(NAME) to $(LATEST)"
	@docker tag $(NAME) $(LATEST)

push-latest:
	@echo "-> pusing container image $(LATEST) to dockerhub"
	@docker push $(LATEST)

login:
	@echo "-> logging into DockerHUB"
	@docker login -u=$(DOCKER_USER) -p=$(DOCKER_PASS)

test:
	@docker run --rm -it -p 80:80 $(NAME)
