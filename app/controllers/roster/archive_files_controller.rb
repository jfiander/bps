# frozen_string_literal: true

class Roster::ArchiveFilesController < RosterController
  def create
    if Roster::ArchiveFile.archive!
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
    params.require(:roster_archive_file).permit(:id)
  end
end