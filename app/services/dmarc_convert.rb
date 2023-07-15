# frozen_string_literal: true

class DmarcConvert
  def initialize(xml)
    @xml = xml
  end

  def to_proto
    noko = Nokogiri::XML(@xml)
    feedback = noko.children.first

    Dmarc::Feedback.new(
      version: value(feedback, :version),
      report_metadata: report_metadata(child(feedback, :report_metadata)),
      policy_published: policy_published(child(feedback, :policy_published)),
      records: records(children(feedback, :record))
    )
  end

private

  def report_metadata(data)
    date_range = child(data, :date_range)

    {
      org_name: value(data, :org_name),
      email: value(data, :email),
      extra_contact_info: value(data, :extra_contact_info),
      report_id: value(data, :report_id),
      date_range: {
        begin: value(date_range, :begin).to_i,
        end: value(date_range, :end).to_i
      },
      error: value(data, :error)
    }
  end

  def policy_published(data)
    {
      domain: value(data, :domain),
      adkim: enum(data, :adkim),
      aspf: enum(data, :aspf),
      p: enum(data, :p),
      sp: enum(data, :sp),
      pct: value(data, :pct).to_i,
      np: enum(data, :np, optional: true),
      fo: value(data, :fo)
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
        source_ip: value(row, :source_ip),
        count: value(row, :count).to_i,
        policy_evaluated: policy_evaluated(child(row, :policy_evaluated))
      },
      identifiers: {
        header_from: value(identifiers, :header_from),
        envelope_from: value(identifiers, :envelope_from)
      },
      auth_results: {
        dkim: dkim(children(auth_results, :dkim)),
        spf: spf(children(auth_results, :spf))
      }
    }
  end

  def policy_evaluated(data)
    reason = child(data, :reason)

    {
      disposition: enum(data, :disposition),
      dkim: enum(data, :dkim),
      spf: enum(data, :spf),
      reason: (reason_data(reason) unless reason.nil?)
    }
  end

  def reason_data(data)
    {
      type: enum(data, :type),
      comment: value(data, :comment)
    }
  end

  def dkim(data)
    data.map do |d|
      {
        domain: value(d, :domain),
        result: enum(d, :result),
        selector: value(d, :selector),
        human_result: value(d, :human_result)
      }
    end
  end

  def spf(data)
    data.map do |s|
      {
        domain: value(s, :domain),
        result: enum(s, :result),
        scope: enum(s, :scope, optional: true)
      }
    end
  end

  def child(node, name)
    node.children.find { |c| c.name == name.to_s }
  end

  def children(node, name)
    node.children.select { |c| c.name == name.to_s }
  end

  def value(node, name, default = '')
    c = child(node, name)
    return c.value if c.respond_to?(:value)

    c&.children&.first&.to_s || default
  end

  def enum(node, name, optional: false)
    return if child(node, name).nil? && optional

    value(node, name).upcase.to_sym
  end
end
