[![Maintainability](https://api.codeclimate.com/v1/badges/b353e4e5606941eec4db/maintainability)](https://codeclimate.com/github/bcgov/cas-shipit/maintainability)
[![img](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

# README

In this repository you'll find:

- A Rails application that uses Shopify's [shipit engine](https://github.com/Shopify/shipit-engine) to provide a continuous deployment application
- A Docker container for the rails application, built following the [Bitnami tutorial](https://docs.bitnami.com/tutorials/secure-optimize-rails-application-bitnami-ruby-production/)
- A Helm chart allowing you to deploy shipit in your OpenShift 4 namespace.

Prerequisites:

- Prior to deploying the helm chart, a "deployer" service account must be provisioned. See our [cas-pipeline](https://github.com/bcgov/cas-pipeline) repository for more information
- When first installing the helm chart, you need to provied a `secret-values.yaml` file containing your github app information. See [the shipit documentation](https://github.com/Shopify/shipit-engine/blob/master/docs/setup.md#updating-the-configsecretsyml) for more information

## Local development

- install the development tools using asdf
  - OSX users might have compilation issues with ruby and might need to disable a warning: `CFLAGS="-Wno-error=implicit-function-declaration" asdf install`
- install ruby gems with `bundle install`
- install npm packages with `yarn install`
- start a postgres db with `pg_ctl start`
- start a redis store with `redis-server`
- seed the development db with `rake db:seed`
- start the rails server with `SHIPIT_DISABLE_AUTH=1 bin/rails s`
- go to `http://localhost:3000/`

## Updating shipit-engine

When updating to a new version of shipit-engine, it is possible that the shipit database schema was updated. To update the migrations in this application, you must run:

```
rake shipit:install:migrations
rake db:migrate
```
