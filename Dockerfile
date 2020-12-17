FROM bitnami/rails:6 as builder
USER root
ENV RAILS_ENV="production"
COPY . /app
WORKDIR /app
RUN apt-get update && \
    apt-get install -y libpq-dev && \
    apt-get clean
RUN gem install bundler:2.2.1 && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test'
RUN bundle install && \
    bundle exec rake assets:precompile

# second stage    
FROM bitnami/ruby:2.6.6-prod as prod
COPY --from=builder /app/ /app/
RUN useradd -r -u 1001 -g root nonroot
RUN chown -R nonroot:0 /app && \
    chmod -R g=u /app
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - && \
    apt-get update && \
    apt-get install -y libpq-dev nodejs && \
    apt-get clean

# bundler needs to be installed and configured as the nonroot user
USER nonroot
ENV HOME="/app"
RUN gem install bundler:2.2.1 && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test'

WORKDIR /app
EXPOSE 3000
ENV RAILS_ENV="production"
CMD ["bin/rails", "server"]