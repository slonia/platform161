Rails.application.routes.draw do
  devise_for :users
  resources :reports, except: [:destroy]

  namespace :api, defaults: { format: :json } do
    resources :reports, only: [:index, :show]
  end

  root 'reports#index'
end
