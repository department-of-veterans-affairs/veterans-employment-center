#!/usr/bin/env puma

ENV['RAILS_RELATIVE_URL_ROOT'] = "/employment"

# Set the environment in which the rack's app will run. The value must be a string.
#
# The default is "development".
#
environment 'production'

# Configure "min" to be the minimum number of threads to use to answer
# requests and "max" the maximum.
#
# The default is "0, 16".
#
threads 16, 16

# === Cluster mode ===

# How many worker processes to run.
#
# The default is "0".
#
workers 3
 
# Verifies that all workers have checked in to the master process within
# the given timeout. If not the worker process will be restarted. Default
# value is 60 seconds.
#
worker_timeout 60


# The below additions from https://github.com/puma/puma#thread-pool and better described in 
#  https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
#
preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end
