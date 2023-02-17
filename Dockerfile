FROM ruby:2.6.6 as base

MAINTAINER lbellet@heliostech.fr

# By default image is built using RAILS_ENV=production.
# You may want to customize it:
#
#   --build-arg RAILS_ENV=development
#
# See https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables-build-arg
#
ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV} APP_HOME=/home/app KAIGARA_VERSION=v1.0.24

# Allow customization of user ID and group ID (it's useful when you use Docker bind mounts)
ARG UID=1000
ARG GID=1000

# Set the TZ variable to avoid perpetual system calls to stat(/etc/localtime)
ENV TZ=UTC

# Create group "app" and user "app".
RUN groupadd -r --gid ${GID} app \
  && useradd --system --create-home --home ${APP_HOME} --shell /sbin/nologin --no-log-init \
  --gid ${GID} --uid ${UID} app

# Install system dependencies.
RUN apt-get update && apt-get upgrade -y
RUN apt-get install default-libmysqlclient-dev -y

# Install Kaigara
RUN curl -Lo /usr/bin/kaigara https://github.com/openware/kaigara/releases/download/${KAIGARA_VERSION}/kaigara \
  && chmod +x /usr/bin/kaigara

WORKDIR $APP_HOME

# Install dependencies defined in Gemfile.
COPY --chown=app:app Gemfile Gemfile.lock $APP_HOME/
RUN mkdir -p /opt/vendor/bundle \
  && gem install bundler:2.1.4 \
  && chown -R app:app /opt/vendor $APP_HOME \
  && su app -s /bin/bash -c "bundle install --jobs $(nproc) --path /opt/vendor/bundle"

# Copy application sources.
COPY --chown=app:app . $APP_HOME

# Switch to application user.
USER app

# Initialize application configuration & assets.
RUN echo "# This file was overridden by default during docker image build." > Gemfile.plugin \
  && ./bin/init_config \
  && chmod +x ./bin/logger \
  && bundle exec rake tmp:create

# Expose port 3000 to the Docker host, so we can access it from the outside.
EXPOSE 3000

# The main command to run when the container starts.
CMD ["bundle", "exec", "puma", "--config", "config/puma.rb"]

# Extend base image with plugins.
FROM base

# Copy Gemfile.plugin for installing plugins.
COPY --chown=app:app Gemfile.plugin Gemfile.lock $APP_HOME/

# Install plugins.
RUN bundle install --path /opt/vendor/bundle --jobs $(nproc)
