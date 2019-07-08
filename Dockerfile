FROM ruby:2.6.3-alpine3.9

RUN apk add --no-cache bash

ENV APPLICATION_PATH /app
RUN mkdir -p $APPLICATION_PATH

WORKDIR $APPLICATION_PATH

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle

ENV PATH="${BUNDLE_BIN}:${PATH}"

COPY . ./

RUN gem install bundler:2.0.1

RUN chmod +x ./docker-entrypoint.sh
