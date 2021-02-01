IMAGE  := mongrelion/blog
TAG    := $$(git log -1 --pretty=%H)
NAME   := $(IMAGE):$(TAG)
LATEST := $(IMAGE):latest

dev:
	@hugo server

site:
	./scripts/build.sh

image: site
	@echo "-> building container image $(NAME)"
	@docker build \
		-t $(NAME)  \
		.

dist: image latest push push-latest
	@./scripts/deploy.sh

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
	@docker run --rm -it -p 1313:1313 -v ${PWD}:/usr/share/hugo mongrelion/hugo:0.20.1 server --bind 0.0.0.0

clean:
	@rm -rf public/
