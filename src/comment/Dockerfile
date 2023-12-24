FROM ruby:2.4-alpine

WORKDIR $APP_HOME
COPY . $APP_HOME

ENV APP_HOME /app
ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

RUN apk --no-cache --update add build-base && \
    bundle install

CMD ["puma"]