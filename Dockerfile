FROM nginx:1.11.13-alpine

MAINTAINER Carlos León <mail@carlosleon.info>

COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./public /usr/share/nginx/html
