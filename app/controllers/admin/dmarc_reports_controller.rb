# frozen_string_literal: true

module Admin
  class DmarcReportsController < ::ApplicationController
    PAGE_SIZE = 10

    secure!(:admin, strict: true)

    def index
      @reports_count = DmarcReport.count
      max_page = (@reports_count.to_f / PAGE_SIZE).ceil
      @page = (params[:page].presence || 1).to_i

      if @page.in?(1..max_page)
        offset = (@page - 1) * PAGE_SIZE
        @last_page = offset + PAGE_SIZE >= @reports_count
      else
        offset = 0
        @page = 1
      end

      @reports = DmarcReport.limit(PAGE_SIZE).offset(offset).order('created_at DESC')
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
