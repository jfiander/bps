# frozen_string_literal: true

module ImportUsers
  class ImportJobcodes
    attr_reader :created, :expired

    def initialize(configs)
      @configs = configs
      @found = []
      @created = []
      @expired = []
    end

    def call
      @configs.map do |config|
        jobcode = Jobcode.find_by(config)

        if jobcode
          @found << jobcode
        else
          @created << Jobcode.create(config)
        end
      end

      current_ids = @found.map(&:id) + @created.map(&:id)

      @expired = Jobcode.where(current: true).where.not(id: current_ids)
      @expired.update_all(current: false) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
