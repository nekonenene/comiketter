Rails.application.routes.draw do
  root to: "home#index"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  devise_scope :user do
    get "logout" => "devise/sessions#destroy", as: :destroy_user_session
  end
end
