#!/usr/bin/env bash
# Render.com build script for Loyalty Card SaaS
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails db:migrate
