production_green_instance = 'green.production.internal.bpsd9.org'

set :rvm_ruby_version, '3.1.3'

role :app, "deploy@#{production_green_instance}"
role :web, "deploy@#{production_green_instance}"
role :db,  "deploy@#{production_green_instance}"

set :environment, 'production'
set :rails_env, 'production'
set :branch, ENV.fetch('BRANCH', 'master')

set :ssh_options, {
  keys: %w(~/.ssh/bpsd9-jfiander.pem ~/.ssh/bpsd9.pem),
  forward_agent: false,
  auth_methods: %w(publickey)
}
