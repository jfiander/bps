# Load all proto descriptors
Dir.glob('lib/proto/descriptors/*_pb.rb').each { |f| require_relative("../../#{f}") }

# Load all extensions, after descriptors
Dir.glob('lib/proto/extensions/*').each { |f| require_relative("../../#{f}") }
