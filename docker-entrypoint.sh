#!/bin/bash
set -e

bundle check || bundle install --binstubs="$BUNDLE_BIN";

gem build ./automatic-sat.gemspec
gem install ./automatic-sat-0.0.1.gem

exec "$@"
