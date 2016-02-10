Rails.application.routes.draw do
  
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :events do
    with_options(constarints: { format: :json }, on: :collection) do
      get 'get_same'
    end
  end

  get 'home/index'
  root 'home#index'
  
end
