class ReportsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    @report.save
    if @report.success?
      flash[:notice] = 'Report generated'
    else
      flash[:error] = 'Problems during report generation. Please, try again later'
    end
    redirect_to reports_path
  end

  def update
    if @report.update_attributes(report_params)
      redirect_to reports_path
    else
      render 'edit'
    end
  end

  def report_params
    params.require(:report).permit(:campaign_id, :comment)
  end
end
