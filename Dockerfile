FROM bitnami/rails:7.0.8 as builder
USER root
ENV RAILS_ENV="production"
COPY . /app
WORKDIR /app
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "ruby" "3.0.2-1"
RUN apt-get update && \
    apt-get install -y libpq-dev && \
    apt-get clean
RUN bundle config set deployment 'true' && \
    bundle config set without 'development test'
RUN bundle install && \
    bundle exec rake assets:precompile

# second stage
FROM bitnami/ruby:3.0.2-prod as prod
COPY --from=builder /app/ /app/
RUN useradd -r -u 1001 -g root nonroot
RUN chown -R nonroot:0 /app && \
    chmod -R g=u /app
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - && \
    apt-get update && \
    apt-get install -y libpq-dev nodejs git make && \
    apt-get clean

RUN curl -L https://downloads-openshift-console.apps.silver.devops.gov.bc.ca/amd64/linux/oc.tar | tar x -C /bin
RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 --output /bin/jq && \
    chmod +x /bin/jq
RUN curl -L https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz | tar xz -C /bin --strip-components 1

# bundler needs to be installed and configured as the nonroot user
USER nonroot
ENV HOME="/app"
RUN gem install bundler && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test'

WORKDIR /app
EXPOSE 3000
ENV RAILS_ENV="production"
CMD ["bin/rails", "server"]
