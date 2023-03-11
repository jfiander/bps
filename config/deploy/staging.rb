staging_instance = 'staging.internal.bpsd9.org'

set :rvm_ruby_version, '2.7.4'

role :app, "deploy@#{staging_instance}"
role :web, "deploy@#{staging_instance}"
role :db,  "deploy@#{staging_instance}"

set :environment, 'staging'
set :branch, ENV.fetch('BRANCH', 'staging')

set :ssh_options, {
  keys: %w(~/.ssh/bpsd9-jfiander.pem ~/.ssh/bpsd9.pem),
  forward_agent: false,
  auth_methods: %w(publickey)
}
