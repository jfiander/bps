# frozen_string_literal: true

# # Creates key files from environment variables
# def self.store_key(path, key = nil, overwrite: true)
#   return if File.exist?(path) && !overwrite

#   File.open(path, 'w+') do |f|
#     File.chmod(0600, f)
#     block_given? ? yield(f) : f.write(key)
#   end
# end

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
