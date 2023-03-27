# frozen_string_literal: true

module BPS
  module Update
    PROTO_PACKAGE = 'b_p_s.update'

    module Helpers
      def empty?
        message_name = "#{PROTO_PACKAGE}.#{self.class.name.demodulize}"
        descriptor = Google::Protobuf::DescriptorPool.generated_pool.lookup(message_name)

        descriptor.all? do |field|
          msg = public_send(field.name)

          if field.label == :repeated || field.type == :message
            msg.nil? || msg.empty?
          elsif field.type == :bool
            !msg
          else
            msg.nil?
          end
        end
      end
    end

    UserDataImport.include(Helpers)
    JobCodes.include(Helpers)
  end
end
