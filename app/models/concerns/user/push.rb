# frozen_string_literal: true

class User
  module Push
    extend ActiveSupport::Concern

    def push(message, title: nil, priority: :normal)
      BpsPush.notify(self, message, title: title, priority: priority)
    end
  end
end
