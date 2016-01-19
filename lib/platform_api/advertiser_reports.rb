class AdvertiserReports
  def initialize(user)
    @auth = user.auth_header
  end

  def generate(groupings: [:campaign], interval: nil)
    groupings = [groupings] unless groupings.is_a?(Array)
    params = {
      advertiser_report: {
        groupings: groupings,
        date_limit: :range,
        start_on: 2.weeks.ago.strftime("%Y-%m-%d"),
        end_on: Date.today.strftime("%Y-%m-%d")
      }
    }
    params[:advertiser_report][:interval] = interval if interval
    url = Rails.application.secrets.api['host'] + 'api/v2/advertiser_reports/'
    response = HTTParty.post(url, query: params, headers: @auth)
  end
end
