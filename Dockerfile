FROM ruby:3.3.0-alpine3.18
RUN apk update
RUN apk add alpine-sdk
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
EXPOSE 3000