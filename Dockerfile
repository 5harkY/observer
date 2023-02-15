FROM ruby:3.1.2-alpine3.16

RUN apk update && apk add bash build-base nodejs postgresql-dev tzdata

RUN mkdir /project
WORKDIR /project

COPY Gemfile Gemfile.lock ./
RUN gem install bundler --no-document
RUN bundle install --no-binstubs --jobs $(nproc) --retry 3

COPY . .

CMD ["rackup", "--host", "0.0.0.0"]