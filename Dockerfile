FROM ruby:3.3.0-alpine3.18
RUN apk add --update alpine-sdk postgresql-dev
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
EXPOSE 3000