class Roster::ArchiveFile < UploadedFile
  def self.table_name_prefix
    'roster_'
  end

  def self.archive!
    generated_at = download_current_roster
    create_new_archive(generated_at)
  end

  def self.download_current_roster
    year = Date.today.strftime('%Y')
    file_name = "Birmingham_Power_Squadron_-_#{year}_Roster.pdf"
    file = buckets[:files].download("roster/#{file_name}")
    File.open("#{Rails.root}/tmp/run/roster.pdf", 'wb') { |f| f.write(file) }

    buckets[:files].object("roster/#{file_name}").last_modified
  end

  def self.create_new_archive(generated_at)
    file = File.open("#{Rails.root}/tmp/run/roster.pdf", 'rb')
    Roster::ArchiveFile.create(file: file, generated_at: generated_at)
  end

  def link
    self.class.buckets[:files].link(file.s3_object.key)
  end
end
