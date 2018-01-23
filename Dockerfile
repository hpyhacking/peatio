FROM ruby:2.5.0
MAINTAINER lbellet@heliostech.fr

# By default image is built using RAILS_ENV=production.
# You may want to customize it:
#
#   --build-arg RAILS_ENV=development
#
# See https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables-build-arg
#
ARG RAILS_ENV=production
ENV RAILS_ENV ${RAILS_ENV}

ENV APP_HOME=/home/app

RUN groupadd -r app --gid=1000
RUN useradd -r -m -g app -d /home/app --uid=1000 app

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && apt-get install -y \
      default-libmysqlclient-dev \
      imagemagick \
      gsfonts \
      chromedriver \
      nodejs \
      yarn

WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock $APP_HOME/

# Install dependencies
RUN mkdir -p /opt/vendor/bundle && chown -R app:app /opt/vendor
RUN su app -s /bin/bash -c "bundle install --path /opt/vendor/bundle"

# Copy the main application.
COPY . $APP_HOME

RUN chown -R app:app /home/app
USER app

RUN ./bin/init_config
RUN bundle exec rake tmp:create yarn:install assets:precompile

# Expose port 8080 to the Docker host, so we can access it
# from the outside.
EXPOSE 8080
ENTRYPOINT ["bundle", "exec"]

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["puma", "--config", "config/puma.rb"]
