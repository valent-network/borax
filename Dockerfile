FROM ruby:3.0.0-alpine

RUN apk update && apk --no-cache add build-base postgresql-dev tzdata git bash

ARG CORONA_ENV
ENV CORONA_ENV $CORONA_ENV

RUN mkdir -p /app/tmp/pids

COPY Gemfile* /tmp/

WORKDIR /tmp

RUN gem update bundler && bundle install -j 4 --full-index --without development test

WORKDIR /app
COPY . /app

CMD bundle exec rake db:create db:migrate && bundle exec clockwork clock.rb
