Rails.application.routes.draw do
  resources :attempts
  resources :challenges, except: %i[show]
  resources :users, only: %i[index]
  post "/login", to: "users#login"
  post "/twilio/guess", to: "twilio#guess"
end
