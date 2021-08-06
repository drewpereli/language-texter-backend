#! /bin/sh

git fetch
git reset --hard origin/main

old_rails_env=$RAILS_ENV

export RAILS_ENV=production

rails db:migrate

cat tmp/pids/server.pid | xargs kill -9

rails server -d

bundle exec whenever --update-crontab

export RAILS_ENV=$old_rails_env

echo "Deployment complete"
