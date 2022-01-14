Rails.application.routes.draw do
  resources :attempts, only: %i[index]
  resources :challenges

  resources :users, only: %i[index create] do
    post "confirm", on: :member
    get "me", on: :collection # always returns the current user, so no need to put it on member
    post "change_password", on: :collection # always changes the password of current_user, so no need to put it on member
    post "login", on: :collection
  end
  
  post "/twilio/guess", to: "twilio#guess"

  resources :student_teachers, only: %i[index destroy]
  resources :student_teacher_invitations, only: %i[index create update destroy]

  resources :languages, only: %i[index]

  resources :user_settings, only: %i[update]
end
