FROM ruby:3.1.0-alpine

RUN apk update && apk --no-cache add build-base postgresql-dev tzdata git bash

RUN mkdir -p /app/tmp/pids

COPY Gemfile* /gems/

ARG CORONA_ENV
ENV CORONA_ENV $CORONA_ENV

WORKDIR /gems

RUN gem install bundler -v 2.2.32
RUN bundle install -j 8 --full-index --without development test

WORKDIR /app

COPY . /app

CMD bundle exec clockwork clock.rb
