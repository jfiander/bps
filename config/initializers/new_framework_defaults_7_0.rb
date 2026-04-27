# Be sure to restart your server when you modify this file.
#
# Ratcheting Rails 7.0 framework defaults on top of `config.load_defaults 6.1`.
# Each option below sets a 7.0 default. Once all are validated in production
# and the commented-out options are addressed, replace `load_defaults 6.1`
# in config/application.rb with `load_defaults 7.0` and delete this file.
#
# https://guides.rubyonrails.org/upgrading_ruby_on_rails.html

# `button_to` view helper renders `<button>` regardless of arg form.
Rails.application.config.action_view.button_to_generates_button_tag = true

# `stylesheet_link_tag` won't render `media="screen"` by default.
Rails.application.config.action_view.apply_stylesheet_media_default = false

# Wrap test cases in `Rails.application.executor.wrap` (closer to a real
# request: enables AR query cache and async queries during tests).
Rails.application.config.active_support.executor_around_test_case = true

# 5-second open and read timeouts on SMTP delivery.
Rails.application.config.action_mailer.smtp_timeout = 5

# Auto-infer `inverse_of` for associations with a scope.
Rails.application.config.active_record.automatic_scope_inversing = true

# Raise in tests when fixtures contain foreign-key violations.
Rails.application.config.active_record.verify_foreign_keys_for_fixtures = true

# Full-column INSERTs (no partial inserts based on default values).
Rails.application.config.active_record.partial_inserts = false

# Raise on user-controlled redirects in `redirect_to` / `redirect_back_or_to`.
Rails.application.config.action_controller.raise_on_open_redirects = true

# Enable parameter wrapping for JSON via the framework default
# (this app already configures it in config/initializers/wrap_parameters.rb,
# so this is a no-op but documents the new default).
Rails.application.config.action_controller.wrap_parameters_by_default = true

# RFC 4122 namespaced UUIDs in Digest::UUID.uuid_v3 / uuid_v5.
Rails.application.config.active_support.use_rfc4122_namespaced_uuids = true

# Default headers: drops legacy XSS protection, keeps the standard hardening set.
Rails.application.config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '0',
  'X-Content-Type-Options' => 'nosniff',
  'X-Download-Options' => 'noopen',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}

# Cookie serializer: transparently re-encode legacy Marshal cookies as JSON
# on read. Safe long-lived setting; once we're confident all cookies have
# been re-encoded we can flip to `:json`.
Rails.application.config.action_dispatch.cookies_serializer = :hybrid

# `ActionDispatch::Request#content_type` returns the raw header value.
Rails.application.config.action_dispatch.return_only_request_media_type_on_content_type = false

# --- Deferred (require coordination) -----------------------------------------
#
# These changes invalidate persisted state (encrypted cookies / cache entries /
# Etags). Each needs a planned rotation or cache flush before flipping. Leave
# them commented until ready, and address them before removing this file.
#
# Rails.application.config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA256
# Rails.application.config.active_support.hash_digest_class = OpenSSL::Digest::SHA256
# Rails.application.config.active_support.remove_deprecated_time_with_zone_name = true
# Rails.application.config.active_storage.variant_processor = :vips  # comes with Phase 2
# Rails.application.config.active_storage.multiple_file_field_include_hidden = true  # Phase 2
# Rails.application.config.active_storage.video_preview_arguments = ...  # Phase 2
#
# These two must live in config/application.rb (not here):
#   config.active_support.cache_format_version = 7.0  # plan a cache flush
#   config.active_support.disable_to_s_conversion = true
