Rails.application.routes.draw do
  post "/login", to: "users#login"
end
