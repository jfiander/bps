Rack::Attack.blocklist('block all PHP requests') do |request|
  request.path.match(/.php$/)
end

# Future feature, not yet released
# Rack::Attack.blocklisted_callback = lambda do |request|
#   [406, {}, ['Format not supported.']]
# end
