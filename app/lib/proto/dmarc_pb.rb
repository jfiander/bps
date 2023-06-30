# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: dmarc.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("dmarc.proto", :syntax => :proto3) do
    add_message "dmarc.Feedback" do
      optional :version, :string, 1
      optional :report_metadata, :message, 2, "dmarc.ReportMetadata"
      optional :policy_published, :message, 3, "dmarc.PolicyPublished"
      repeated :records, :message, 4, "dmarc.Record"
    end
    add_message "dmarc.ReportMetadata" do
      optional :org_name, :string, 1
      optional :email, :string, 2
      optional :extra_contact_info, :string, 3
      optional :report_id, :string, 4
      optional :date_range, :message, 5, "dmarc.DateRange"
      optional :error, :string, 6
    end
    add_message "dmarc.DateRange" do
      optional :begin, :int32, 1
      optional :end, :int32, 2
    end
    add_message "dmarc.PolicyPublished" do
      optional :domain, :string, 1
      optional :adkim, :enum, 2, "dmarc.PolicyPublished.Alignment"
      optional :aspf, :enum, 3, "dmarc.PolicyPublished.Alignment"
      optional :p, :enum, 4, "dmarc.Disposition"
      optional :sp, :enum, 5, "dmarc.Disposition"
      optional :pct, :int32, 6
      optional :np, :string, 7
      optional :fo, :string, 8
    end
    add_enum "dmarc.PolicyPublished.Alignment" do
      value :UNKNOWN_ALIGNMENT, 0
      value :R, 1
      value :S, 2
    end
    add_message "dmarc.Record" do
      optional :row, :message, 1, "dmarc.Row"
      optional :identifiers, :message, 2, "dmarc.Identifiers"
      optional :auth_results, :message, 3, "dmarc.AuthResults"
    end
    add_message "dmarc.Row" do
      optional :source_ip, :string, 1
      optional :count, :int32, 2
      optional :policy_evaluated, :message, 3, "dmarc.PolicyEvaluated"
    end
    add_message "dmarc.PolicyEvaluated" do
      optional :disposition, :enum, 1, "dmarc.Disposition"
      optional :dkim, :string, 2
      optional :spf, :string, 3
      optional :reason, :message, 4, "dmarc.Reason"
    end
    add_message "dmarc.Reason" do
      optional :type, :enum, 1, "dmarc.Reason.PolicyOverride"
      optional :comment, :string, 2
    end
    add_enum "dmarc.Reason.PolicyOverride" do
      value :UNKNOWN_POLICY_OVERRIDE, 0
      value :FORWARDED, 1
      value :SAMPLED_OUT, 2
      value :TRUSTED_FORWARDER, 3
      value :MAILING_LIST, 4
      value :LOCAL_POLICY, 5
      value :OTHER, 6
    end
    add_message "dmarc.Identifiers" do
      optional :header_from, :string, 1
      optional :envelope_from, :string, 2
    end
    add_message "dmarc.AuthResults" do
      repeated :dkim, :message, 1, "dmarc.Dkim"
      repeated :spf, :message, 2, "dmarc.Spf"
    end
    add_message "dmarc.Dkim" do
      optional :domain, :string, 1
      optional :result, :enum, 2, "dmarc.Result"
      optional :selector, :string, 3
      optional :human_result, :string, 4
    end
    add_message "dmarc.Spf" do
      optional :domain, :string, 1
      optional :result, :enum, 2, "dmarc.Spf.SpfResult"
      optional :scope, :string, 3
    end
    add_enum "dmarc.Spf.SpfResult" do
      value :UNKNOWN_SPF_RESULT, 0
      value :NONE, 1
      value :NEUTRAL, 2
      value :PASS, 3
      value :FAIL, 4
      value :SOFTFAIL, 5
      value :TEMPERROR, 6
      value :PERMERROR, 7
      value :ERROR, 8
    end
    add_enum "dmarc.Disposition" do
      value :UNKNOWN_DISPOSITION, 0
      value :NONE, 1
      value :QUARANTINE, 2
      value :REJECT, 3
    end
    add_enum "dmarc.Result" do
      value :UNKNOWN_RESULT, 0
      value :PASS, 1
      value :FAIL, 2
    end
  end
end

module Dmarc
  Feedback = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Feedback").msgclass
  ReportMetadata = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.ReportMetadata").msgclass
  DateRange = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.DateRange").msgclass
  PolicyPublished = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.PolicyPublished").msgclass
  PolicyPublished::Alignment = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.PolicyPublished.Alignment").enummodule
  Record = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Record").msgclass
  Row = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Row").msgclass
  PolicyEvaluated = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.PolicyEvaluated").msgclass
  Reason = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Reason").msgclass
  Reason::PolicyOverride = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Reason.PolicyOverride").enummodule
  Identifiers = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Identifiers").msgclass
  AuthResults = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.AuthResults").msgclass
  Dkim = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Dkim").msgclass
  Spf = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Spf").msgclass
  Spf::SpfResult = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Spf.SpfResult").enummodule
  Disposition = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Disposition").enummodule
  Result = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("dmarc.Result").enummodule
end
