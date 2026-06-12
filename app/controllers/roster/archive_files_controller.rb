# frozen_string_literal: true

module Roster
  class ArchiveFilesController < ::RosterController
    def create
      status = Roster::ArchiveFile.archive!
      if status == :current
        flash[:notice] = 'Latest archive is current.'
      elsif status
        flash[:success] = 'Successfully archived current roster.'
      else
        flash[:alert] = 'Unable to archive current roster.'
      end
      redirect_to roster_archive_files_path
    end

  private

    def model
      Roster::ArchiveFile
    end

    def clean_params
      params.expect(roster_archive_file: [:id])
    end
  end
end
