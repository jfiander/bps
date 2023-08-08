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
    child(feedback, :report_metadata) do |data|
      {
        org_name: string(data, :org_name),
        email: string(data, :email),
        extra_contact_info: string(data, :extra_contact_info),
        report_id: string(data, :report_id),
        date_range: date_range(data),
        error: string(data, :error)
      }
    end
  end

  def date_range(metadata)
    child(metadata, :date_range) do |data|
      {
        begin: integer(data, :begin),
        end: integer(data, :end)
      }
    end
  end

  def policy_published(feedback)
    child(feedback, :policy_published) do |data|
      {
        domain: string(data, :domain),
        adkim: enum(data, :adkim),
        aspf: enum(data, :aspf),
        p: enum(data, :p),
        sp: enum(data, :sp, optional: true),
        pct: integer(data, :pct),
        np: enum(data, :np, optional: true),
        fo: string(data, :fo)
      }
    end
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
    child(record, :row) do |data|
      {
        source_ip: string(data, :source_ip),
        count: integer(data, :count),
        policy_evaluated: policy_evaluated(data)
      }
    end
  end

  def identifiers(record)
    child(record, :identifiers) do |data|
      {
        header_from: string(data, :header_from),
        envelope_from: string(data, :envelope_from)
      }
    end
  end

  def auth_results(record)
    child(record, :auth_results) do |data|
      {
        dkim: dkim(data),
        spf: spf(data)
      }
    end
  end

  def policy_evaluated(row)
    child(row, :policy_evaluated) do |data|
      {
        disposition: enum(data, :disposition),
        dkim: enum(data, :dkim),
        spf: enum(data, :spf),
        reason: reason(data)
      }
    end
  end

  def reason(policy_evaluated)
    child(policy_evaluated, :reason) do |data|
      return if data.nil?

      {
        type: enum(data, :type),
        comment: string(data, :comment)
      }
    end
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
    result = node.children.find { |c| c.name == name.to_s }

    block_given? ? yield(result) : result
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
