FROM ruby:2.4-alpine

ENV APP_HOME /app
ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

WORKDIR /app
ADD . $APP_HOME

RUN apk --no-cache --update add build-base && \
    bundle install

CMD ["puma"]
