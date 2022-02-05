# frozen_string_literal: true

namespace :cognito do
  desc 'Import users into Cognito'
  task import: :environment do
    raise 'Can only run user import in production.' unless Rails.env.production?

    admin = BPS::Cognito::Admin.new
    migrate = BPS::Cognito::Migrate.new

    User.unlocked.each do |user|
      print "Migrating active #{user.id}\t#{user.certificate}"

      did_import_username = migrate.migrate_user(user)
      print ' - Imported' if did_import_username
      print "\n"
    end

    User.locked.each do |user|
      print "Migrating locked #{user.id}\t#{user.certificate}"

      did_import_username = migrate.migrate_user(user)
      next unless did_import_username

      print ' - Imported'
      admin.disable(did_import_username)
      puts ' - Locked'
    end
  end

  desc 'Update pool config with re-rendered email templates'
  task config: :environment do
    BPS::Cognito::Config.new.update
  end
end
