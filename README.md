# Birmingham Power Squadron – 2018 Website

[![Build Status](https://img.shields.io/travis/jfiander/bps/master.svg)](https://travis-ci.org/jfiander/bps)
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

### Environment Variables

```sh
# General
LANG # en_US.UTF-8
ACTIVITY_FEED_LENGTH

# Flags
ALLOW_BULK_INVITE # false
ENABLE_BRAINTREE # enabled, or CSV user ids
MARK_EXTERNAL_LINKS # enabled
NEW_HEADER # enabled
RAILS_LOG_TO_STDOUT # enabled
RAILS_SERVE_STATIC_FILES # enabled

# Stage
DOMAIN # staging.bpsd9.org
ASSET_ENVIRONMENT # staging
BUGSNAG_RELEASE_STAGE # staging
RACK_ENV # production - all deployed servers use production
RAILS_ENV # production - all deployed servers use production
NEW_RELIC_APP_NAME # BPSD9 (Staging)

# Keys, IDs, and Versions
BRAINTREE_MERCHANT_ID
BRAINTREE_PRIVATE_KEY
BRAINTREE_PUBLIC_KEY
BUGSNAG_KEY
CALENDARS # this is only used to read from calendar(s)
CF_ENC_IV
CF_ENC_KEY
CLOUDFRONT_KEYPAIR_ID
EXCOM_MEET_ID
EXCOM_MEET_SIGNATURE
FACEBOOK_PIXEL_ID # only used in production
FONTAWESOME_INTEGRITY
FONTAWESOME_VERSION
GA_TRACKING_ID
GOOGLE_ACCESS_TOKEN
GOOGLE_AUTH_EXP
GOOGLE_CALENDAR_API_CLIENT
GOOGLE_CALENDAR_ICON_URI
GOOGLE_CALENDAR_ID_EDUC
GOOGLE_CALENDAR_ID_GEN
GOOGLE_CALENDAR_ID_TEST
GOOGLE_CALENDAR_TOKEN
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
GOOGLE_GEOCODER_API_KEY
GOOGLE_REFRESH_TOKEN
MEMBERSHIP_MEET_ID
MEMBERSHIP_MEET_SIGNATURE
NEW_RELIC_LICENSE_KEY
S3_ACCESS_KEY
S3_SECRET
SECRET_KEY_BASE
SENDGRID_PASSWORD
SENDGRID_USERNAME
SIGNATURE_IV # enc keys for educational certificate signature
SIGNATURE_KEY # enc keys for educational certificate signature
SLACK_URL_EDUCATION
SLACK_URL_EXCOM
SLACK_URL_FLOATPLANS
SLACK_URL_GENERAL
SLACK_URL_NOTIFICATIONS
SLACK_URL_WEBSITE
SMS_ORIGINATION_NUMBER
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

Builds are generated automatically by [Travis CI](https://travis-ci.org/jfiander/bps).

Build success requires both `rspec` and `rubocop` to pass.

## Licensing

This website and its design are Copyright © 2017 Birmingham Power Squadron. All rights reserved.

The USPS Ensign (Flag Design), "Wheel-and-Flag Design", "Officer Trident Design","United States Power Squadrons", "USPS", "The Ensign", "the Squadron" with flag graphic, "USPS Trade Dress", "Paddle Smart", "USPS University", "Boat Smart", "Jet Smart", and "America's Boating Club" are registered trademarks of United States Power Squadrons.

"The Squadron Boating Course", "For Boaters, By Boaters", "Come for the boating education... Stay for the friends.", are service marks of United States Power Squadrons.
