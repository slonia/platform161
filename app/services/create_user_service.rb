class CreateUserService
  def call
    user = User.find_or_create_by!(email: Rails.application.secrets.user_email) do |user|
      user.nickname = Rails.application.secrets.user_nickname
      user.password = Rails.application.secrets.user_password
      user.password_confirmation = Rails.application.secrets.user_password
    end
  end
end
