FROM ruby:2.4.2
MAINTAINER lbellet@heliostech.fr

ENV APP_HOME=/home/app

RUN groupadd -r app --gid=1000
RUN useradd -r -m -g app -d /home/app --uid=1000 app

RUN apt-get update \
 && apt-get install -y \
      libmysqlclient-dev \
      imagemagick \
      gsfonts \
      chromedriver

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
RUN bundle exec rake tmp:create assets:precompile

# Expose port 8080 to the Docker host, so we can access it
# from the outside.
EXPOSE 8080
ENTRYPOINT ["bundle", "exec"]

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["puma", "--config", "config/puma.rb"]
