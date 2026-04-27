production_instance = 'production.internal.bpsd9.org'

role :app, "deploy@#{production_instance}"
role :web, "deploy@#{production_instance}"
role :db,  "deploy@#{production_instance}"

set :environment, 'production'
set :branch, ENV.fetch('BRANCH', 'master')

set :bundle_jobs, 1

set :ssh_options, {
  keys: %w(~/.ssh/bpsd9_deploy ~/.ssh/bpsd9.pem),
  forward_agent: false,
  auth_methods: %w(publickey)
}
