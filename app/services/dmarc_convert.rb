# frozen_string_literal: true

class DmarcConvert
  def initialize(xml)
    @xml = xml
  end

  def to_proto
    noko = Nokogiri::XML(@xml)
    feedback = noko.children.first

    Dmarc::Feedback.new(
      version: string(feedback, :version),
      report_metadata: report_metadata(feedback),
      policy_published: policy_published(feedback),
      records: records(feedback)
    )
  end

private

  def report_metadata(feedback)
    data = child(feedback, :report_metadata)

    {
      org_name: string(data, :org_name),
      email: string(data, :email),
      extra_contact_info: string(data, :extra_contact_info),
      report_id: string(data, :report_id),
      date_range: date_range(data),
      error: string(data, :error)
    }
  end

  def date_range(metadata)
    data = child(metadata, :date_range)

    {
      begin: integer(data, :begin),
      end: integer(data, :end)
    }
  end

  def policy_published(feedback)
    data = child(feedback, :policy_published)

    {
      domain: string(data, :domain),
      adkim: enum(data, :adkim),
      aspf: enum(data, :aspf),
      p: enum(data, :p),
      sp: enum(data, :sp),
      pct: integer(data, :pct),
      np: enum(data, :np, optional: true),
      fo: string(data, :fo)
    }
  end

  def records(feedback)
    children(feedback, :record).map do |record|
      {
        row: row(record),
        identifiers: identifiers(record),
        auth_results: auth_results(record)
      }
    end
  end

  def row(record)
    data = child(record, :row)

    {
      source_ip: string(data, :source_ip),
      count: integer(data, :count),
      policy_evaluated: policy_evaluated(data)
    }
  end

  def identifiers(record)
    data = child(record, :identifiers)

    {
      header_from: string(data, :header_from),
      envelope_from: string(data, :envelope_from)
    }
  end

  def auth_results(record)
    data = child(record, :auth_results)

    {
      dkim: dkim(data),
      spf: spf(data)
    }
  end

  def policy_evaluated(row)
    data = child(row, :policy_evaluated)

    {
      disposition: enum(data, :disposition),
      dkim: enum(data, :dkim),
      spf: enum(data, :spf),
      reason: reason(data)
    }
  end

  def reason(policy_evaluated)
    data = child(policy_evaluated, :reason)
    return if data.nil?

    {
      type: enum(data, :type),
      comment: string(data, :comment)
    }
  end

  def dkim(auth_results)
    children(auth_results, :dkim).map do |d|
      {
        domain: string(d, :domain),
        result: enum(d, :result),
        selector: string(d, :selector),
        human_result: string(d, :human_result)
      }
    end
  end

  def spf(auth_results)
    children(auth_results, :spf).map do |s|
      {
        domain: string(s, :domain),
        result: enum(s, :result),
        scope: enum(s, :scope, optional: true)
      }
    end
  end

  ### Parsing Helpers ###

  def child(node, name)
    node.children.find { |c| c.name == name.to_s }
  end

  def children(node, name)
    node.children.select { |c| c.name == name.to_s }
  end

  def string(node, name)
    c = child(node, name)
    return c.value if c.respond_to?(:value)

    c&.children&.first&.to_s
  end

  def integer(node, name)
    string(node, name).to_i
  end

  def enum(node, name, optional: false)
    return if child(node, name).nil? && optional

    string(node, name).upcase.to_sym
  end
end
