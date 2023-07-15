# frozen_string_literal: true

# Usage in model:
#   serialize :proto, Proto::Message::Name
#
# Usage in extension config:
#   Proto::Message::Name.extend(ProtoSerialize)
#
module ProtoSerialize
  # Decode
  def load(data)
    data ? decode(data) : new
  end

  # Encode
  def dump(data)
    case data
    when self
      data.to_proto
    when Hash
      new(data).to_proto
    when String
      decode(data).to_proto # Decode/encode to validate
    else
      raise 'Unexpected data format'
    end
  end
end
