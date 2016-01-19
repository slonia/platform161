module ApiAuth
  extend ActiveSupport::Concern

  def api_token
    super() || get_token
  end

  def get_token
    credentials = {
      user: Rails.application.secrets.api['user'],
      password: Rails.application.secrets.api['password'],
      client_id: Rails.application.secrets.api['client_id'],
      client_secret: Rails.application.secrets.api['client_secret']
    }
    url = Rails.application.secrets.api['host'] + '/api/v2/access_tokens/'
    response = HTTParty.post(url, query: credentials)
    token = response['token']
    self.update_attributes(api_token: token)
    token
  end

  def auth_header
    {
      'PFM161-API-AccessToken' => api_token
    }
  end

  def get_all_tokens
    url = Rails.application.secrets.api['host'] + '/api/v2/access_tokens/'
    response = HTTParty.get(url, headers: auth_header)
    response.select { |token| token['active'] }
  end
end
