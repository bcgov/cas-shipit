FROM bitnami/rails:6 as builder
USER root
ENV RAILS_ENV="production"
COPY . /app
WORKDIR /app
RUN apt-get update &&  apt-get install libpq-dev
RUN bundle config set deployment 'true' && \
    bundle config set without 'development test'
RUN bundle install && \
    bundle exec rake assets:precompile

# second stage    
FROM bitnami/ruby:2.7.2-prod as prod
COPY --from=builder /app/ /app/
RUN useradd -r -u 1001 -g root nonroot
RUN chown -R nonroot /app
USER nonroot
WORKDIR /app
EXPOSE 3000
ENV RAILS_ENV="production"
CMD ["bin/rails", "server"]