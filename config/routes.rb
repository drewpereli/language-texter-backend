Rails.application.routes.draw do
  resources :attempts
  resources :challenges, except: %i[show]
  resources :users, only: %i[index]
  post "/login", to: "users#login"
  post "/change_password", to: "users#change_password"
  post "/twilio/guess", to: "twilio#guess"
end
