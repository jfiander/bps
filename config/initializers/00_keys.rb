# frozen_string_literal: true

EncryptedKeystore.decrypt(
  file: File.join(Rails.root, 'config', 'keys', 'cf.pem.enc'),
  out: Rails.root.join('config', 'keys', 'cf.pem'),
  key: ENV['CF_ENC_KEY'], iv: ENV['CF_ENC_IV']
)
