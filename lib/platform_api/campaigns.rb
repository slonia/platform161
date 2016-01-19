class Campaigns
  def initialize(user)
    @auth = user.auth_header
  end

  def index
    url = Rails.application.secrets.api['host'] + 'api/v2/campaigns/'
    response = HTTParty.get(url, headers: @auth)
  end

  def get(id)
    url = Rails.application.secrets.api['host'] + 'api/v2/campaigns/' + id.to_s
    response = HTTParty.get(url, headers: @auth)
  end
end
