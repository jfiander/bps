remote_host = 'cap.production-green.bpsd9.org'

role :app, "julian@#{remote_host}"
role :web, "julian@#{remote_host}"
role :db,  "julian@#{remote_host}"

set :environment, 'production'
set :rails_env, 'production'
set :branch, ENV.fetch('BRANCH', 'master')

set :bundle_jobs, 1
