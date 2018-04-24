Rails.application.routes.draw do
  devise_for :admins
  devise_for :students

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "semesters#index"
  get 'sign_in', to: 'login#choose'
  get 'sign_out', to: 'login#sign_out'

  resources :semesters do
    resources :weeks, only: [:create, :new, :edit, :update, :destroy]
    resources :assignments, only: [:index, :destroy]
  end

  resources :weeks do
    resources :assignments, only: [:create, :new, :edit, :update]
    resources :resources
  end

  resources :assignments do
    resources :submissions
  end

  resources :students do
    resources :attendances
  end

end
