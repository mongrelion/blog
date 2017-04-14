IMAGE := mongrelion/blog
TAG   := 2.0.0
NAME  := $(IMAGE):$(TAG)

site:
	@docker run                \
		--rm                     \
		-it                      \
		-v $$PWD:/usr/share/hugo \
		mongrelion/hugo:0.20.1

container: site
	@docker build \
		-t $(NAME)  \
		.

test:
	@docker run --rm -it -p 80:80 $(NAME)
