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
      report_metadata: report_metadata(child(feedback, :report_metadata)),
      policy_published: policy_published(child(feedback, :policy_published)),
      records: records(children(feedback, :record))
    )
  end

private

  def report_metadata(data)
    date_range = child(data, :date_range)

    {
      org_name: string(data, :org_name),
      email: string(data, :email),
      extra_contact_info: string(data, :extra_contact_info),
      report_id: string(data, :report_id),
      date_range: {
        begin: integer(date_range, :begin),
        end: integer(date_range, :end)
      },
      error: string(data, :error)
    }
  end

  def policy_published(data)
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

  def records(data)
    data.map do |r|
      record(
        child(r, :row),
        child(r, :auth_results),
        child(r, :identifiers)
      )
    end
  end

  def record(row, auth_results, identifiers)
    {
      row: {
        source_ip: string(row, :source_ip),
        count: integer(row, :count),
        policy_evaluated: policy_evaluated(child(row, :policy_evaluated))
      },
      identifiers: {
        header_from: string(identifiers, :header_from),
        envelope_from: string(identifiers, :envelope_from)
      },
      auth_results: {
        dkim: dkim(children(auth_results, :dkim)),
        spf: spf(children(auth_results, :spf))
      }
    }
  end

  def policy_evaluated(data)
    reason_data = child(data, :reason)

    {
      disposition: enum(data, :disposition),
      dkim: enum(data, :dkim),
      spf: enum(data, :spf),
      reason: (reason(reason_data) unless reason_data.nil?)
    }
  end

  def reason(data)
    {
      type: enum(data, :type),
      comment: string(data, :comment)
    }
  end

  def dkim(data)
    data.map do |d|
      {
        domain: string(d, :domain),
        result: enum(d, :result),
        selector: string(d, :selector),
        human_result: string(d, :human_result)
      }
    end
  end

  def spf(data)
    data.map do |s|
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
