# frozen_string_literal: true

module Admin
  class DmarcReportsController < ::ApplicationController
    secure!(:admin, strict: true)

    def index
      @reports = DmarcReport.all
      @new_report = DmarcReport.new
    end

    def show
      @report = DmarcReport.find(params[:id])

      respond_to do |format|
        format.html
        format.xml { render(xml: @report.xml) }
        format.json { render(plain: @report.proto.to_json) }
        format.proto { render(plain: @report.proto.to_proto) }
      end
    end

    def create
      content_type = dmarc_report_params[:xml].content_type
      case content_type
      when 'text/xml'
        DmarcReport.create(xml: dmarc_report_params[:xml].read)
      when 'application/zip'
        extract_zip(dmarc_report_params[:xml])
      when 'application/x-gzip'
        DmarcReport.create(
          xml: Zlib::GzipReader.new(dmarc_report_params[:xml]).read
        )
      else
        raise "Unexpected file format: #{content_type}"
      end

      redirect_to(admin_dmarc_reports_path)
    end

  private

    def dmarc_report_params
      params.require(:dmarc_report).permit(:xml)
    end

    def extract_zip(xml)
      Zip::File.open(xml) do |zip_file|
        zip_file.each do |entry|
          DmarcReport.create(xml: entry.get_input_stream.read)
        end
      end
    end
  end
end
