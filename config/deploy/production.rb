staging_instance = 'ssh.www.bpsd9.org'

role :app, "deploy@#{staging_instance}"
role :web, "deploy@#{staging_instance}"
role :db,  "deploy@#{staging_instance}"

set :branch, ENV.fetch('BRANCH', 'master')

set :ssh_options, {
  keys: %w(~/.ssh/bpsd9-jfiander.pem),
  forward_agent: false,
  auth_methods: %w(publickey)
}
