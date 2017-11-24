Rails.application.routes.draw do
  root to: "home#index"

  get "auth/:provider/signin", to: "auth#signin", format: false, as: :auth_signin
  get "auth/:provider/callback", to: "auth#create", format: false
  get "auth/signout", to: "auth#signout", format: false
end
