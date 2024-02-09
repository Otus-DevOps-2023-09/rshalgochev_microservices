FROM fluent/fluentd:v1.16.0-1.0
USER root
RUN fluent-gem install fluent-plugin-elasticsearch --no-document --version 5.0.3 && \
    fluent-gem install fluent-plugin-grok-parser --no-document --version 2.0.0
ADD fluent.conf /fluentd/etc
