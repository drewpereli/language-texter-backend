Rails.application.routes.draw do
  resources :users, only: %i[index]
  post "/login", to: "users#login"
end
