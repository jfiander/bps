# Birmingham Power Squadron – 2018 Website

[![Status](https://github.com/jfiander/bps/actions/workflows/main.yml/badge.svg)](https://github.com/jfiander/bps/actions/workflows/main.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/96881399c3ad513707e3/maintainability)](https://codeclimate.com/github/jfiander/bps/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/96881399c3ad513707e3/test_coverage)](https://codeclimate.com/github/jfiander/bps/test_coverage)

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

Set environment variables as appropriate – expected variables are listed below.

Run the server:

```sh
rails s
```

## Deploy

Deploys are handled through Capistrano.

Environment variables must be set in: config/application.yml

| Description                  | Command                                                     |
|------------------------------|-------------------------------------------------------------|
| Update environment variables | `bundle exec cap <ENVIRONMENT> setup`                       |
| Deploy                       | `bundle exec cap <ENVIRONMENT> deploy [BRANCH=branch_name]` |
| Restart                      | `bundle exec cap <ENVIRONMENT> passenger:restart`           |

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

Builds are generated automatically by [Travis CI](https://travis-ci.org/jfiander/bps).

Build success requires both `rspec` and `rubocop` to pass.

## Licensing

This website and its design are Copyright © 2017 Birmingham Power Squadron. All rights reserved.

The USPS Ensign (Flag Design), "Wheel-and-Flag Design", "Officer Trident Design","United States Power Squadrons", "USPS", "The Ensign", "the Squadron" with flag graphic, "USPS Trade Dress", "Paddle Smart", "USPS University", "Boat Smart", "Jet Smart", and "America's Boating Club" are registered trademarks of United States Power Squadrons.

"The Squadron Boating Course", "For Boaters, By Boaters", "Come for the boating education... Stay for the friends.", are service marks of United States Power Squadrons.
