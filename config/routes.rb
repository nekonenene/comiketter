Rails.application.routes.draw do
  root to: "home#index"

  resources :auth, only: [:destroy], format: false
  get "auth/:provider/new", to: "auth#new", format: false, as: :auth_new
  get "auth/:provider/callback", to: "auth#create", format: false
end
