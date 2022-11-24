# frozen_string_literal: true

# spec/support/request_spec_helper.rb

module RequestSpecHelper
  def jwt_authorization_header(user)
    jwt = JWT.encode({ sub: user.id, jti: user.jti }, Rails.application.secrets.secret_key_base)

    { 'Authorization' => "Bearer #{jwt}" }
  end
end
