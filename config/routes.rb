Rails.application.routes.draw do
  resources :attempts
  resources :challenges, except: %i[show]
  resources :users, only: %i[index]
  post "/login", to: "users#login"
end
