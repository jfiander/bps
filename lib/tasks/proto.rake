# frozen_string_literal: true

namespace :proto do
  desc 'Compile proto definitions using protoc'
  task compile: :environment do
    dir = Rails.root.join('lib/proto/descriptors')
    proto_files = Dir.glob("#{dir}/*.proto")
    `protoc --proto_path="#{dir}" --ruby_out="#{dir}" #{proto_files.join(' ')}`
  end
end
