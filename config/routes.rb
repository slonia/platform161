Rails.application.routes.draw do
  devise_for :users
  resources :reports do
    get :pdf_report, on: :member
  end
  root 'reports#index'
end
