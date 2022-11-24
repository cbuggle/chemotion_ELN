# frozen_string_literal: true

module Users
  class ApiSessionsController < Devise::SessionsController
    private

    def respond_with(_resource, _opts = {})
      respond_to do |format|
        format.json do
          render json: { message: 'You are logged in.', user: UserSerializer.new(current_user).to_json, status: :ok }
        end
      end
    end

    def respond_to_on_destroy
      log_out_success && return if current_user

      respond_to do |format|
        format.json { render json: { message: 'You are logged out.' }, status: :unauthorized }
      end
    end

    def log_out_success
      respond_to do |format|
        format.json { render json: { message: 'You are logged out.' }, status: :ok }
      end
    end
  end
end
