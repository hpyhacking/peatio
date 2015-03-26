FROM phusion/passenger-full
MAINTAINER PEATIO community@peatio.com

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN apt update
RUN apt-get -y install imagemagick gsfonts

ADD peatio /home/app/peatio
RUN chown -R app:app /home/app/peatio

USER app
ENV HOME /home/app

WORKDIR /home/app/peatio
RUN bundle install --without development test --path vendor/bundle

# RUN ./bin/init_config
ADD conf/rails-amqp.yml /home/app/peatio/config/amqp.yml
ADD conf/rails-database.yml /home/app/peatio/config/database.yml
ADD conf/rails-application.yml /home/app/peatio/config/application.yml
ADD conf/nginx-peatio-env.conf /etc/nginx/main.d/peatio-env.conf

USER root

RUN rm /etc/nginx/sites-enabled/default
ADD conf/nginx-peatio-with-ssl.conf /etc/nginx/sites-available/peatio
RUN ln -s /etc/nginx/sites-available/peatio /etc/nginx/sites-enabled/peatio

RUN mkdir /etc/nginx/ssl_keys/
ADD conf/ssl_keys/server.crt /etc/nginx/ssl_keys/server.crt
ADD conf/ssl_keys/server.key /etc/nginx/ssl_keys/server.key

RUN chown -R app:app /home/app/peatio/config

RUN rm -f /etc/service/nginx/down

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
