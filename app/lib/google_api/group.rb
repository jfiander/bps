# frozen_string_literal: true

module GoogleAPI
  class Group < GoogleAPI::Base
    def initialize(id, auth: false)
      @group_id = id
      super(auth: auth)
    end

    def get
      service.get_group(@group_id)
    end

    def members
      service.list_members(@group_id)
    end

    def add(email)
      service.insert_member(@group_id, member(email))
    end

    def remove(email)
      service.delete_member(@group_id, email)
    end

  private

    def service_class
      Google::Apis::AdminDirectoryV1::DirectoryService
    end

    def member(email)
      Google::Apis::AdminDirectoryV1::Member.new(email: email)
    end
  end
end