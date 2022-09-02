# frozen_string_literal: true

module BPS
  module Update
    PROTO_PACKAGE = 'b_p_s.update'

    class UserDataImport
      def empty?
        message_name = "#{PROTO_PACKAGE}.#{self.class.name.demodulize}"
        descriptor = Google::Protobuf::DescriptorPool.generated_pool.lookup(message_name)

        descriptor.all? do |field|
          if field.label == :repeated
            public_send(field.name).empty?
          elsif field.type == :bool
            !public_send(field.name)
          else
            public_send(field.name).nil?
          end
        end
      end
    end
  end
end
