class ReportsController < ApplicationController
  load_resource

  def index
    @reports = Report.all
  end

  def pdf_report
    @pdf = @report.generate_pdf
    send_data(@pdf, filename: "report.pdf", type: "application/pdf")
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    @report.save
    redirect_to reports_path
  end

  def report_params
    params.require(:report).permit(:campaign_id)
  end
end
