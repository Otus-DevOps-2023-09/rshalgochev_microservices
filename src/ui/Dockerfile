FROM ruby:2.4-alpine

WORKDIR $APP_HOME
COPY . $APP_HOME

ENV APP_HOME /app
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

RUN apk --no-cache --update add build-base && \
    bundle install

CMD ["puma"]
