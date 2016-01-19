class Creatives
  def initialize(user)
    @auth = user.auth_header
  end

  def index
    url = Rails.application.secrets.api['host'] + 'api/v2/creatives/'
    response = HTTParty.get(url, headers: @auth)
  end

  def get(id)
    url = Rails.application.secrets.api['host'] + 'api/v2/creatives/' + id.to_s
    response = HTTParty.get(url, headers: @auth)
  end
end
