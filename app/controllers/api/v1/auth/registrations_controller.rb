module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController

        def create
          user = User.new(sign_up_params)

          if user.save
          sign_in(user, store: false)
            render json: response_payload(user), status: :created
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
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
