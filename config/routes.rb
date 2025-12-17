Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users,
             skip: %i[registrations sessions],
             controllers: {
               registrations: "api/v1/auth/registrations",
               sessions: "api/v1/auth/sessions"
             }

  namespace :api do
    namespace :v1 do
      resources :stress_records, only: [:create] do
        collection do
          get "weekly/:user_id", action: :weekly, as: :weekly
          get "availability/:user_id", action: :availability, as: :availability
        end
      end

      namespace :auth do
        devise_scope :user do
          post :sign_up, to: "registrations#create"
          post :sign_in, to: "sessions#create"
          delete :sign_out, to: "sessions#destroy"
          %i[sign_up sign_in sign_out].each do |path|
            match path, to: proc { |_env| [204, {}, []] }, via: :options
          end
        end
      end
    end
  end
end
