class Auth
  def get_token
    credentials = {
      user: Rails.application.secrets.api['user'],
      password: Rails.application.secrets.api['password'],
      client_id: Rails.application.secrets.api['client_id'],
      client_secret: Rails.application.secrets.api['client_secret']
    }
    url = Rails.application.secrets.api['host'] + '/api/v2/access_tokens/'
    response = HTTParty.post(url, query: credentials)
    response['token']
  end
end
