# Extend base image with plugins.
FROM rubykube/peatio:latest

# Copy Gemfile.plugin for installing plugins.
COPY Gemfile.plugin $APP_HOME

# Install plugins.
RUN bundle install --path /opt/vendor/bundle
