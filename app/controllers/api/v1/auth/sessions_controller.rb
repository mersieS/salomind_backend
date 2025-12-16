module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        skip_before_action :verify_authenticity_token
        before_action :authenticate_user!, only: :destroy

        def create
          user = User.find_for_database_authentication(email: sign_in_params[:email])

          if user&.valid_password?(sign_in_params[:password])
            sign_in(user)
            render json: response_payload(user), status: :ok
          else
            render json: { errors: ['Geçersiz e-posta veya parola'] }, status: :unauthorized
          end
        end

        def destroy
          sign_out(current_user)
          head :no_content
        end

        private

        def sign_in_params
          params.require(:user).permit(:email, :password)
        end

        def response_payload(user)
          {
            user: {
              id: user.id,
              email: user.email
            },
            token: request.env['warden-jwt_auth.token']
          }
        end
      end
    end
  end
end
