class AdvertiserReports
  def initialize
    token = Auth.new.get_token
    @auth = {
      'PFM161-API-AccessToken' => token
    }
  end

  def generate
    params = {
      advertiser_report: {
        groupings: [ :campaign ],
        meaures:   [ :impressions, :clicks, :conversions ],
        period:    :last_30_days
      }
    }
    url = Rails.application.secrets.api['host'] + 'api/v2/advertiser_reports/'
    response = HTTParty.post(url, query: params, headers: @auth)
  end
end
