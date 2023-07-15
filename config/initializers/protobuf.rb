# Load all proto descriptors
Dir.glob('lib/proto/descriptors/*_pb.rb').each { |f| require_relative("../../#{f}") }

# Load all extensions, after descriptors, in file order
Dir.glob('lib/proto/extensions/*').sort.each { |f| require_relative("../../#{f}") }
