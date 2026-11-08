# frozen_string_literal: true

# Ingests the DMARC aggregate reports that the ProcessDmarcReportRuby Lambda (bps/infrastructure) validated and stored
# on S3, through the same model as a manual upload.
#
# Objects are moved to the processed prefix only after a successful ingest (or a confirmed duplicate), so a report that
# fails to process stays in the validated prefix for the next run.
class DmarcReportIngestJob < ApplicationJob
  VALIDATED_PREFIX = 'dmarc/validated/'
  PROCESSED_PREFIX = 'dmarc/processed/'

  def perform
    s3.list(VALIDATED_PREFIX).map(&:key).each { |key| ingest(key) }
  end

private

  def s3
    @s3 ||= BPS::S3.new(:dmarc_reports)
  end

  def ingest(key)
    import(key)
    archive(key)
  rescue StandardError => e
    raise unless Rails.env.production? # Bugsnag doesn't report from development or test; surface the error instead

    Bugsnag.notify('Error ingesting DMARC report') do |report|
      report.add_metadata(:dmarc, { key:, error: e.message })
    end
  end

  def import(key)
    filename = File.basename(key)
    report = DmarcReport.create!(xml: s3.download(key), auto: true, filename:)

    slack(:success, 'DMARC Report Imported', 'ID' => report.id, 'Filename' => filename)
  rescue ActiveRecord::RecordInvalid => e
    raise unless e.message == 'Validation failed: Duplicate report'

    # Already ingested, so it is archived like a new import.
    slack(:info, 'DMARC Duplicate Report Scanned', 'Filename' => filename)
  end

  # Keeps the date path: dmarc/validated/YYYY/MM/DD/<file> moves to dmarc/processed/YYYY/MM/DD/<file>.
  def archive(key) = s3.move(key, key.sub(VALIDATED_PREFIX, PROCESSED_PREFIX))

  def slack(type, title, fields)
    SlackNotification.new(channel: :notifications, type:, title:, fallback: title, fields:).notify!
  end
end
