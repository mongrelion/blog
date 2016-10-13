FROM ruby:2.3.1

MAINTAINER Carlos León, mail@carlosleon.info

ENV RACK_ENV production

EXPOSE 9292

WORKDIR /usr/src/app

COPY . /usr/src/app

RUN bundle install --deployment

ENTRYPOINT ["/usr/local/bin/bundle", "exec", "puma"]

CMD ["-v", "-b", "tcp://0.0.0.0:9292"]
