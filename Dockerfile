FROM ruby:2.2-onbuild

MAINTAINER Carlos León, mail@carlosleon.info

ENV RACK_ENV production

EXPOSE 9292

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:9292", "-e", $RACK_ENV]
