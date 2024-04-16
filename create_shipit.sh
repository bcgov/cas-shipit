set -euxo pipefail

gem install rails -v 7.1
rails _7.1_ new shipit --skip-action-cable \
                       --skip-turbolinks \
                       --skip-action-mailer \
                       --skip-active-storage \
                       --skip-webpack-install \
                       --skip-action-mailbox \
                       --skip-action-text \
                       -m https://raw.githubusercontent.com/Shopify/shipit-engine/v0.39.0/template.rb
