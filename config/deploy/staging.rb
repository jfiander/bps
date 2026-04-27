remote_host = 'cap.staging.bpsd9.org'

role :app, "julian@#{remote_host}"
role :web, "julian@#{remote_host}"
role :db,  "julian@#{remote_host}"

set :environment, 'staging'
set :branch, ENV.fetch('BRANCH', 'staging')

set :bundle_jobs, 1
