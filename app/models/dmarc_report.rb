# frozen_string_literal: true

class DmarcReport < ApplicationRecord
  before_validation { self.proto = to_proto }

  validate :check_report_uniqueness

  def proto
    Dmarc::Feedback.decode(read_attribute(:proto))
  end

  def proto=(data)
    new_proto =
      case data
      when Hash
        Dmarc::Feedback.new(data)
      when Dmarc::Feedback
        data
      else
        raise 'Unexpected data format'
      end

    write_attribute(:proto, new_proto.to_proto)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/BlockLength
  def to_proto
    noko = Nokogiri::XML(xml)
    feedback = noko.children.first
    report_metadata = child(feedback, :report_metadata)
    date_range = child(report_metadata, :date_range)
    policy_published = child(feedback, :policy_published)
    records = children(feedback, :record)

    record_data = records.each_with_object([]) do |record, array|
      record_data = {}
      row = child(record, :row)
      record_data[:source_ip] = value(row, :source_ip)
      record_data[:count] = value(row, :count)
      record_data[:policy_evaluated] = policy_evaluated = child(row, :policy_evaluated)
      record_data[:reason] = child(policy_evaluated, :reason)
      record_data[:identifiers] = child(record, :identifiers)
      record_data[:auth_results] = auth_results = child(record, :auth_results)
      record_data[:dkim] = children(auth_results, :dkim)
      record_data[:spf] = children(auth_results, :spf)
      array << record_data
    end

    Dmarc::Feedback.new(
      version: value(feedback, :version),
      report_metadata: {
        org_name: value(report_metadata, :org_name),
        email: value(report_metadata, :email),
        extra_contact_info: value(report_metadata, :extra_contact_info),
        report_id: value(report_metadata, :report_id),
        date_range: {
          begin: value(date_range, :begin).to_i,
          end: value(date_range, :end).to_i
        },
        error: value(report_metadata, :error)
      },
      policy_published: {
        domain: value(policy_published, :domain),
        adkim: enum(policy_published, :adkim),
        aspf: enum(policy_published, :aspf),
        p: enum(policy_published, :p),
        sp: enum(policy_published, :sp),
        pct: value(policy_published, :pct).to_i,
        np: if_present(child(policy_published, :np)) { enum(policy_published, :np) },
        fo: value(policy_published, :fo)
      },
      records: record_data.map do |data|
        {
          row: {
            source_ip: data[:source_ip],
            count: data[:count].to_i,
            policy_evaluated: {
              disposition: enum(data[:policy_evaluated], :disposition),
              dkim: enum(data[:policy_evaluated], :dkim),
              spf: enum(data[:policy_evaluated], :spf),
              reason: if_present(data[:reason]) do
                {
                  type: enum(data[:reason], :type),
                  comment: value(data[:reason], :comment)
                }
              end
            }
          },
          identifiers: {
            header_from: value(data[:identifiers], :header_from),
            envelope_from: value(data[:identifiers], :envelope_from)
          },
          auth_results: {
            dkim: data[:dkim].map do |d|
              {
                domain: value(d, :domain),
                result: enum(d, :result),
                selector: value(d, :selector),
                human_result: value(d, :human_result)
              }
            end,
            spf: data[:spf].map do |s|
              {
                domain: value(s, :domain),
                result: enum(s, :result),
                scope: if_present(child(s, :scope)) { enum(s, :scope) }
              }
            end
          }
        }
      end
    )
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/BlockLength

  def identifier
    [proto.report_metadata.org_name, proto.report_metadata.report_id]
  end

  def ==(other)
    identifier == other.identifier
  end

private

  def child(node, name)
    node.children.find { |c| c.name == name.to_s }
  end

  def children(node, name)
    node.children.select { |c| c.name == name.to_s }
  end

  def value(node, name, default = '')
    c = child(node, name)
    c.respond_to?(:value) ? child(node, name)&.value : c&.children&.first&.to_s || default
  end

  def enum(node, name)
    value(node, name).upcase.to_sym
  end

  def if_present(node)
    yield unless node.nil?
  end

  def check_report_uniqueness
    return if DmarcReport.all.none? { |report| self == report && id != report.id }

    errors.add(:base, 'Duplicate report')
  end
end
