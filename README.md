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

Set the minimum required environment variables:

```sh
S3_ACCESS_KEY
S3_SECRET

CLOUDFRONT_KEYPAIR_ID
CLOUDFRONT_PRIVATE_KEY_PATH

ASSET_ENVIRONMENT

CLOUDFRONT_STATIC_ENDPOINT
CLOUDFRONT_FILES_ENDPOINT
CLOUDFRONT_BILGE_ENDPOINT
CLOUDFRONT_PHOTOS_ENDPOINT
```

And any optional environment variables you want to support:

```sh
CALENDARS

NEW_RELIC_LICENSE_KEY

SLACK_NOTIFIER_URL
```

Run the server:

```sh
rails s
```

## Testing

Rspec testing is available:

`bundle exec rspec`

## Licensing

This website and its design are Copyright © 2017 Birmingham Power Squadron. All rights reserved.

The USPS Ensign (Flag Design), "Wheel-and-Flag Design", "Officer Trident Design","United States Power Squadrons", "USPS", "The Ensign", "the Squadron" with flag graphic, "USPS Trade Dress", "Paddle Smart", "USPS University", "Boat Smart", "Jet Smart", and "America's Boating Club" are registered trademarks of United States Power Squadrons.

"The Squadron Boating Course", "For Boaters, By Boaters", "Come for the boating education... Stay for the friends.", are service marks of United States Power Squadrons.
