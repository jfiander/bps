# frozen_string_literal: true

Aws.config[:stub_responses] = true

Aws.config[:s3] = {
  stub_responses: {
    get_object: {
      body: StringIO.new('something goes here')
    }
  }
}

def distro(key)
  {
    id: "test_#{key}_distro_id", status: 'Deployed',
    arn: "arn:aws:cloudfront::test_distro:distribution:test_#{key}_distro_id",
    domain_name: 'something.cloudfront.net', last_modified_time: Time.zone.now,
    aliases: { items: ["#{key}.development.bpsd9.org"], quantity: 1 },
    origins: { items: [{ id: 'stub', domain_name: "stub_#{key}.bpsd9.org" }], quantity: 1 },
    default_cache_behavior: {
      target_origin_id: 'stub', viewer_protocol_policy: 'stub', min_ttl: 1,
      forwarded_values: { query_string: false, cookies: { forward: 'stub' } },
      trusted_signers: { enabled: true, quantity: 1, items: ['stub'] }
    },
    cache_behaviors: { quantity: 0 }, custom_error_responses: { quantity: 0 },
    restrictions: { geo_restriction: { restriction_type: 'none', quantity: 0 } },
    comment: 'stub', price_class: 'Standard', enabled: true, staging: false,
    viewer_certificate: {}, web_acl_id: 'stub', http_version: '1.2', is_ipv6_enabled: false
  }
end

Aws.config[:cloudfront] = {
  stub_responses: {
    create_invalidation: {
      invalidation: {
        id: 'test_invalidation', status: 'InProgress', create_time: Time.zone.now,
        invalidation_batch: {
          paths: { quantity: 1, items: ['/dev/test_file'] },
          caller_reference: 'test_caller_reference'
        }
      }
    },
    list_distributions: {
      distribution_list: {
        items: [
          distro(:files),
          distro(:bilge)
        ],
        marker: '12345', max_items: 2, is_truncated: false, quantity: 2
      }
    },
    list_invalidations: {
      invalidation_list: {
        marker: 'marker',
        max_items: 100,
        is_truncated: false,
        quantity: 1,
        items: [
          {
            id: 'I3TUSXES93FBM3',
            create_time: 1.minute.ago,
            status: 'InProgress'
          }
        ]
      }
    }
  }
}
