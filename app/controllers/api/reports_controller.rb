class Api::ReportsController < ApplicationController
  before_filter :authenticate_user_from_token!
  skip_before_action :verify_authenticity_token
  load_and_authorize_resource

  def index
    render json: @reports.to_json(
      only: [:id, :created_at, :campaign_id, :start_on, :end_on, :status])
  end

  def show
    render json: @report.to_json(
      only: [:id, :created_at, :campaign_id, :status, :start_on, :end_on,
       :comment, :impressions, :clicks, :ctr, :conversions],
      methods: [:ecpm, :ecpc, :ecpa])
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    if @report.save && @report.success?
      render json: { status: 'ok', message: 'Report created'}
    else
      render json: { status: 'error', message: 'Problems during report generation. Please, try again later'}
    end
  end

  private

    def report_params
      params.permit(:campaign_id)
    end

    def authenticate_user_from_token!
      user_token = params[:auth_token]
      user = user_token && User.find_by_authentication_token(user_token)
      if user
        sign_in user, store: false
      else
        render json: {error: 'Please, provide valid auth_token'}
      end

    end
end
