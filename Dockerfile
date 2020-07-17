FROM ruby:1.9.3

RUN apt-get install libpq-dev

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
#RUN bundle update
RUN bundle config --delete frozen
RUN bundle install

#COPY . .

CMD ["rackup", "config.ru"]
