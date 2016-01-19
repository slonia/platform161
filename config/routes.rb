Rails.application.routes.draw do
  devise_for :users
  resources :reports
  root 'reports#index'
end
