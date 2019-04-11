# frozen_string_literal: true

module GoogleAPI
  class Group < GoogleAPI::Base
    def initialize(id, auth: true)
      @group_id = id
      super(auth: auth)
    end

    def get
      call(:get_group, @group_id)
    end

    def members
      call(:list_members, @group_id)
    end

    def add(email)
      call(:insert_member, @group_id, member(email))
    rescue Google::Apis::ClientError, 'duplicate: Member already exists.'
      :already_exists
    end

    def remove(email)
      call(:delete_member, @group_id, email)
    rescue Google::Apis::ClientError, '(required: Missing required field: memberKey)'
      :not_found
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
