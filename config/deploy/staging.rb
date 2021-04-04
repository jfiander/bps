staging_instance = 'ssh.staging.bpsd9.org'

role :app, "deploy@#{staging_instance}"
role :web, "deploy@#{staging_instance}"
role :db,  "deploy@#{staging_instance}"

set :branch, ENV.fetch('BRANCH', 'staging')

set :ssh_options, {
  keys: %w(~/.ssh/bpsd9-jfiander.pem),
  forward_agent: false,
  auth_methods: %w(publickey)
}
