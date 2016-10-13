NAME := mongrelion/blog
TAG := 0.1.0
IMAGE := $(NAME):$(TAG)

image:
	@docker build -t $(NAME):$(TAG) .

run:
	@docker run --rm -it -p 9292:9292 $(NAME):$(TAG)

irb:
	@docker run --rm -it --entrypoint /usr/local/bin/bundle $(IMAGE) exec irb -f -r ./deps
