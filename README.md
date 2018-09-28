# Birmingham Power Squadron – 2018 Website

[![Build Status](https://travis-ci.org/jfiander/bps.svg)](https://travis-ci.org/jfiander/bps)
[![Maintainability](https://api.codeclimate.com/v1/badges/96881399c3ad513707e3/maintainability)](https://codeclimate.com/github/jfiander/bps/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/96881399c3ad513707e3/test_coverage)](https://codeclimate.com/github/jfiander/bps/test_coverage)

## Location

| Environment | URL                                                     |
|-------------|---------------------------------------------------------|
| Production  | [https://www.bpsd9.org](https://www.bpsd9.org)          |
| Staging     | [https://staging.bpsd9.org](https://staging.bpsd9.org)  |

## Assets

All assets are served by CloudFront.

Static files are stored in one bucket.

All other files are stored in environment-specific buckets by purpose.

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

# Flags
ALLOW_BULK_INVITE # false
ENABLE_BRAINTREE # enabled, or CSV user ids
MARK_EXTERNAL_LINKS # enabled
NEW_HEADER # enabled
RAILS_LOG_TO_STDOUT # enabled
RAILS_SERVE_STATIC_FILES # enabled
USE_NEW_AG_TITLES # disabled, or CSV old course titles

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
CALENDARS # gen_cal_id_1:99FF99/educ_cal_id_2:3399FF - this is only used to read
CLOUDFRONT_KEYPAIR_ID
CLOUDFRONT_PRIVATE_KEY
EXCOM_MEET_ID
EXCOM_MEET_SIGNATURE
FACEBOOK_PIXEL_ID # only used in production
FONTAWESOME_INTEGRITY
FONTAWESOME_VERSION # v5.3.1
GA_TRACKING_ID
GOOGLE_ACCESS_TOKEN
GOOGLE_CALENDAR_API_CLIENT
GOOGLE_CALENDAR_ICON_URI
GOOGLE_CALENDAR_ID_EDUC
GOOGLE_CALENDAR_ID_GEN
GOOGLE_CALENDAR_ID_TEST
GOOGLE_CALENDAR_TOKEN
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
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
```

## Testing

Rspec testing is available:

`bundle exec rspec`

Not included in coverage stats:

- Controller specs
- View-oriented helper code
- Link signing
- Events partial desktop/mobile renderer
- Code used to configure gems or API access

## Licensing

This website and its design are Copyright © 2017 Birmingham Power Squadron. All rights reserved.

The USPS Ensign (Flag Design), "Wheel-and-Flag Design", "Officer Trident Design","United States Power Squadrons", "USPS", "The Ensign", "the Squadron" with flag graphic, "USPS Trade Dress", "Paddle Smart", "USPS University", "Boat Smart", "Jet Smart", and "America's Boating Club" are registered trademarks of United States Power Squadrons.

"The Squadron Boating Course", "For Boaters, By Boaters", "Come for the boating education... Stay for the friends.", are service marks of United States Power Squadrons.
