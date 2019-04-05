# frozen_string_literal: true

# Creates key files from environment variables
def self.store_key(path, key = nil, overwrite: true)
  return if File.exist?(path) && !overwrite

  File.open(path, 'w+') do |f|
    File.chmod(0600, f)
    block_given? ? yield(f) : f.write(key)
  end
end

def decrypt_cf_key
  cf_key_enc = File.join(Rails.root, 'config', 'keys', 'cf.pem.enc')

  cipher = OpenSSL::Cipher.new('aes-256-cbc')
  cipher.decrypt
  cipher.key = Base64.decode64(ENV['CF_ENC_KEY'])
  cipher.iv = Base64.decode64(ENV['CF_ENC_IV'])

  buffer = +''
  File.open("#{Rails.root}/config/keys/cf.pem", 'wb') do |outfile|
    File.open(cf_key_enc, 'rb') do |infile|
      outfile << cipher.update(buffer) while infile.read(4096, buffer)
      outfile << cipher.final
    end
  end
end

# def encrypt_cf_key
#   cf_key = File.join(Rails.root, 'config', 'keys', 'cf.pem')

#   cipher = OpenSSL::Cipher.new('aes-256-cbc')
#   cipher.encrypt
#   key = Base64.encode64(cipher.random_key)
#   iv = Base64.encode64(cipher.random_iv)

#   buffer = +''
#   File.open(File.join(Rails.root, 'config', 'keys', 'cf.pem.enc'), 'wb') do |outfile|
#     File.open(File.join(Rails.root, 'config', 'keys', 'cf.pem'), 'rb') do |infile|
#       outfile << cipher.update(buffer) while infile.read(4096, buffer)
#       outfile << cipher.final
#     end
#   end

#   { key: key, iv: iv }
# end

decrypt_cf_key

store_key('config/keys/google_api_client.json') do |f|
  f.write('{"installed":{"client_id":"')
  f.write(ENV['GOOGLE_CLIENT_ID'])
  f.write('","project_id":"charming-scarab-208718",')
  f.write('"auth_uri":"https://accounts.google.com/o/oauth2/auth",')
  f.write('"token_uri":"https://accounts.google.com/o/oauth2/token",')
  f.write('"auth_provider_x509_cert_url":')
  f.write('"https://www.googleapis.com/oauth2/v1/certs",')
  f.write('"client_secret":"')
  f.write(ENV['GOOGLE_CLIENT_SECRET'])
  f.write('","redirect_uris":["urn:ietf:wg:oauth:2.0:oob",')
  f.write('"http://localhost"]}}')
end

store_key('config/keys/google_token.yaml') do |f|
  f.write("---\n")
  f.write("default: '")
  f.write('{"client_id":"')
  f.write(ENV['GOOGLE_CLIENT_ID'])
  f.write('","access_token":"')
  f.write(ENV['GOOGLE_ACCESS_TOKEN'])
  f.write('","refresh_token":"')
  f.write(ENV['GOOGLE_REFRESH_TOKEN'])
  f.write('","scope":[')
  f.write(ENV['GOOGLE_AUTH_SCOPES'])
  f.write('],')
  f.write('"expiration_time_millis":')
  f.write(ENV['GOOGLE_AUTH_EXP'])
  f.write('}')
  f.write("'\n")
end
