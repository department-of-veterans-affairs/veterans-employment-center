FROM ruby:2.3-slim-jessie

# required by rails for the production DB
ARG database_password
ENV EMPLOYMENTPORTAL_DATABASE_PASSWORD=$database_password
ENV APP_PATH /srv/vec

RUN mkdir -p $APP_PATH

ADD . $APP_PATH

RUN groupadd -r vec && \
useradd -r -g vec vec && \
apt-get update -qq && \
apt-get install -y build-essential \
git \
libpq-dev

WORKDIR $APP_PATH

RUN bundle install -j 4 --without development