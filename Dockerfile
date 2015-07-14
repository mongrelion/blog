FROM mongrelion/ruby:2.2.2

MAINTAINER Carlos León, mail@carlosleon.info

ENV RACK_ENV production

EXPOSE 9292

WORKDIR /usr/src/app

RUN git clone https://github.com/mongrelion/carlosleon.info . && \
    bundle install --deployment

ENTRYPOINT ["/usr/local/bundle/bin/bundle", "exec", "puma"]

CMD ["-b", "tcp://0.0.0.0:9292"]
