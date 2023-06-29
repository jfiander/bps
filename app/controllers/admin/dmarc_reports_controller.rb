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
    end

    def create
      content_type = 'application/x-gzip'
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
          entry.extract
          DmarcReport.create(xml: entry.get_input_stream.read)
        end
      end
    end
  end
end
