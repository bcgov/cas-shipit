# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.12
FROM dhi.io/ruby:$RUBY_VERSION-dev as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config nodejs libpq-dev

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Create a revision file for shipit
RUN bundle info shipit-engine --version > REVISION

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Create and make runtime directories group-writable so the nonroot user can write to them.
RUN mkdir -p db log storage tmp && \
    chmod -R g+rwX /rails && \
    chmod -R g+rwX /usr/local/bundle

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 nodejs libpq-dev jq git make gzip && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install oc and helm to /usr/local/bin to be used by the nonroot user
RUN curl -L https://downloads-openshift-console.apps.silver.devops.gov.bc.ca/amd64/linux/oc.tar | tar x -C /usr/local/bin
RUN curl -L https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz | tar xz -C /usr/local/bin --strip-components 1

# Final stage for app image
FROM dhi.io/ruby:$RUBY_VERSION

WORKDIR /rails

# Helm needs to write a few directories in the HOME of the user
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    HOME="/rails"

# Copy application from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Copy packages needed for deployment
COPY --from=build /usr/local/bin/oc /usr/local/bin/oc
COPY --from=build /usr/local/bin/helm /usr/local/bin/helm
COPY --from=build /usr/lib /usr/lib
COPY --from=build /usr/share/git-core /usr/share/git-core
COPY --from=build /usr/bin/git* /usr/bin/
COPY --from=build /usr/bin/jq /usr/bin/
COPY --from=build /usr/bin/node /usr/bin/

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
