class Roster::ArchiveFile < UploadedFile
  def self.table_name_prefix
    'roster_'
  end

  def self.archive!
    return :current if roster_generated_at == last&.generated_at
    download_current_roster
    create_new_archive(roster_generated_at)
  end

  def self.download_current_roster
    file = buckets[:files].download("roster/#{roster_file_name}")
    File.open("#{Rails.root}/tmp/run/roster.pdf", 'wb') { |f| f.write(file) }
  end

  def self.create_new_archive(generated_at)
    file = File.open("#{Rails.root}/tmp/run/roster.pdf", 'rb')
    Roster::ArchiveFile.create(file: file, generated_at: generated_at)
  end

  def self.roster_file_name
    year = Date.today.strftime('%Y')
    "Birmingham_Power_Squadron_-_#{year}_Roster.pdf"
  end

  def self.roster_generated_at
    buckets[:files].object("roster/#{roster_file_name}").last_modified
  end

  def link
    self.class.buckets[:files].link(file.s3_object.key)
  end
end
