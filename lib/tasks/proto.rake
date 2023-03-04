# frozen_string_literal: true

namespace :proto do
  desc 'Compile proto definitions using protoc'
  task compile: :environment do
    dir = Rails.root.join('app', 'lib', 'proto')
    proto_files = Dir.glob("#{dir}/*.proto")
    Dir.glob("#{dir}/*_pb.rb").each { |p| File.unlink(p) } # Clean ruby files
    `protoc --proto_path="#{dir}" --ruby_out="#{dir}" #{proto_files.join(' ')}`
  end
end
