class Api::ReportsController < ApplicationController
  before_filter :authenticate_user_from_token!
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

  private

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
