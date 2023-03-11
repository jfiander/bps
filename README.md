# Birmingham Power Squadron – 2018 Website

[![Status](https://github.com/jfiander/bps/actions/workflows/main.yml/badge.svg)](https://github.com/jfiander/bps/actions/workflows/main.yml)

## Location

| Environment | URL                                                     |
|-------------|---------------------------------------------------------|
| Production  | [https://www.bpsd9.org](https://www.bpsd9.org)          |
| Staging     | [https://staging.bpsd9.org](https://staging.bpsd9.org)  |

## Assets

All assets are served by CloudFront.

Static assets and SEO files are stored in one bucket each.

Photos, Bilge issues, and general files are stored in environmented buckets.

## Setup

Ensure you have Ruby and RubyGems installed.

Install required gems:

  ```sh
  gem install bundler
  bundle install
  ```

Run migrations to setup the database:

```sh
bundle exec rails db:setup
```

Set environment variables as appropriate.

Run the server:

```sh
rails s
```

## Upgrading Ruby

To upgrade the deployed Ruby version, make sure to update the following locations:

- Gemfile
- config/deploy/*
- nginx site configuration file

## Deploy

Deploys are handled through Capistrano.

Environment variables must be set in: `config/application.yml`

| Description                  | Command                                                     |
|------------------------------|-------------------------------------------------------------|
| Update environment variables | `bundle exec cap <ENVIRONMENT> setup`                       |
| Deploy                       | `bundle exec cap <ENVIRONMENT> deploy [BRANCH=branch_name]` |
| Restart                      | `bundle exec cap <ENVIRONMENT> passenger:restart`           |

### Sidekiq

Sidekiq will be automatically restarted on deploy. It can also be manually controlled without
needing to redeploy the entire application.

| Description                | Command                                         |
|----------------------------|-------------------------------------------------|
| Start service              | `bundle exec cap <ENVIRONMENT> sidekiq:start`   |
| Restart service            | `bundle exec cap <ENVIRONMENT> sidekiq:restart` |
| Stop service               | `bundle exec cap <ENVIRONMENT> sidekiq:stop`    |
| Copy service configuration | `bundle exec cap <ENVIRONMENT> sidekiq:setup`   |

#### Permissions

These tasks require some `sudo` permissions.

```
# /etc/sudoers.d/deploy

deploy ALL = NOPASSWD: /usr/sbin/service sidekiq start, /usr/sbin/service sidekiq stop, /usr/sbin/service sidekiq restart, /usr/bin/systemctl daemon-reload
```

## Testing

### Rspec

Rspec testing is available:

`bundle exec rspec`

Not included in coverage stats:

- Controllers
- View-oriented helper code
- Events partial desktop/mobile renderer
- Code used to configure gems or API access

The spec suite will fail if under 100% coverage.

### Rubocop

Rubocop formatting validation is available:

`bundle exec rubocop`

### Automatic Builds

Builds are generated automatically by [GitHub Actions](https://github.com/jfiander/bps/actions).

Build success requires both `rspec` and `rubocop` to pass.

## Licensing

This website and its design are Copyright © 2017 Birmingham Power Squadron. All rights reserved.

The USPS Ensign (Flag Design), "Wheel-and-Flag Design", "Officer Trident Design","United States Power Squadrons", "USPS", "The Ensign", "the Squadron" with flag graphic, "USPS Trade Dress", "Paddle Smart", "USPS University", "Boat Smart", "Jet Smart", and "America's Boating Club" are registered trademarks of United States Power Squadrons.

"The Squadron Boating Course", "For Boaters, By Boaters", "Come for the boating education... Stay for the friends.", are service marks of United States Power Squadrons.
