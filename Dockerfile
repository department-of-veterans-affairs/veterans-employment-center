FROM ruby:2.3-slim-jessie

# required by rails for the production DB
ARG database_password
ENV EMPLOYMENTPORTAL_DATABASE_PASSWORD=$database_password
ENV APP_PATH /srv/vec
ENV PHANTOM phantomjs-2.1.1
ENV LANG C.UTF-8

RUN mkdir -p $APP_PATH

ADD . $APP_PATH

ADD https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM-linux-x86_64.tar.bz2 /tmp
WORKDIR /tmp
RUN tar xvjf /tmp/$PHANTOM-linux-x86_64.tar.bz2 && \
    mv /tmp/$PHANTOM-linux-x86_64 /usr/local/share && \
    ln -sf /usr/local/share/$PHANTOM-linux-x86_64/bin/phantomjs /usr/local/bin && \
    rm /tmp/$PHANTOM-linux-x86_64.tar.bz2

RUN groupadd -r vec && \
useradd -r -g vec vec && \
apt-get update -qq && \
apt-get install -y build-essential \
git \
libpq-dev \
libfontconfig \
&& rm -rf /var/lib/apt/lists/*

WORKDIR $APP_PATH

RUN bundle install -j 4 --without development
