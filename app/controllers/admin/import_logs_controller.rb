# frozen_string_literal: true

module Admin
  class ImportLogsController < ::ApplicationController
    secure!(:admin)

    def index
      @import_logs = ImportLog.where.not(proto: nil)
    end

    def show
      @import_log = ImportLog.find_by(id: params[:id])
    end
  end
end
