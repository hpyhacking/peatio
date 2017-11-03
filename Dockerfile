FROM ruby:2.2.1

RUN apt-get update && apt-get install -y nodejs libmysqlclient-dev

## RUN curl -sL https://kaigara.org/get | bash

RUN groupadd -r app --gid=1000
RUN useradd -r -m -g app -d /home/app --uid=1000 app

WORKDIR /home/app

ENV BUNDLE_PATH=/bundle

ADD Gemfile /home/app/Gemfile
ADD Gemfile.lock /home/app/Gemfile.lock

RUN bundle install

ADD . /home/app

RUN chown -R app:app /home/app /bundle
USER app

EXPOSE 8080

CMD ["bundle", "exec", "rails", "server", "-p", "8080", "-b", "0.0.0.0"]
