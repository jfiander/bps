# frozen_string_literal: true

class DmarcReport < ApplicationRecord
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

    record_data = records.each_with_object({}) do |record, hash|
      hash[record] ||= {}
      row = child(record, :row)
      hash[record][:policy_evaluated] = policy_evaluated = child(row, :policy_evaluated)
      hash[record][:reason] = child(policy_evaluated, :reason)
      hash[record][:identifiers] = child(record, :identifiers)
      hash[record][:auth_results] = auth_results = child(record, :auth_results)
      hash[record][:dkim] = children(auth_results, :dkim)
      hash[record][:spf] = children(auth_results, :spf)
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
        np: value(policy_published, :np),
        fo: value(policy_published, :fo)
      },
      records: record_data.map do |record, data|
        {
          row: {
            source_ip: value(record, :source_ip),
            count: value(record, :count).to_i,
            policy_evaluated: {
              disposition: enum(data[:policy_evaluated], :disposition),
              dkim: value(data[:policy_evaluated], :dkim),
              spf: value(data[:policy_evaluated], :spf),
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
                result: handle_unknown_spf(enum(s, :result)),
                scope: value(s, :scope)
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

  def handle_unknown_spf(result)
    result == :UNKNOWN ? :TEMPERROR : result
  end
end
