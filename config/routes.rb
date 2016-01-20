Rails.application.routes.draw do
  devise_for :users
  resources :reports, except: [:show, :destroy]

  namespace :api, defaults: { format: :json } do
    resources :reports, only: [:index, :show, :create]
  end

  root 'reports#index'
end
