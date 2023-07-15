# frozen_string_literal: true

class DmarcReport < ApplicationRecord
  RECOGNIZED_SENDERS = {
    GOOGLE: /\.google\.com$/,
    AMAZON: /smtp-out\.us-east-2\.amazonses\.com$/
  }.freeze

  before_validation { self.proto = DmarcConvert.new(xml).to_proto }
  before_create :record_sources

  validate :check_report_uniqueness

  serialize :proto, Dmarc::Feedback
  serialize :sources_proto, Dmarc::SourcesSummary

  def identifier
    [proto.report_metadata.org_name, proto.report_metadata.report_id]
  end

  def ==(other)
    identifier == other.identifier
  end

private

  def check_report_uniqueness
    return if DmarcReport.all.none? { |report| self == report && id != report.id }

    errors.add(:base, 'Duplicate report')
  end

  def record_sources
    source_ips = proto.records.flat_map(&:row).map(&:source_ip)
    source_dns = source_ips.map { |ip| reverse_dns(ip) }
    self.sources_proto = Dmarc::SourcesSummary.new(
      sources: source_ips.zip(source_dns).map do |ip, dns|
        { source_ip: ip, dns: dns, sender: dmarc_sender(dns) }
      end
    )
  end

  # :nocov:
  def reverse_dns(ip)
    Resolv.getname(ip)
  rescue StandardError
    nil
  end
  # :nocov:

  def dmarc_sender(dns)
    RECOGNIZED_SENDERS.each do |sender, pattern|
      return sender if dns&.match?(pattern)
    end

    nil # No match found
  end
end
