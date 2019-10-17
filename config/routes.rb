Rails.application.routes.draw do
  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

  namespace :api do
    namespace :v1 do
      resources :races, only: %i[index]
      resources :character_classes, only: %i[index]
      resources :characters, only: %i[show create update]
    end
  end

  resources :worlds, except: %i[show]
  resources :subscribes, only: %i[create update]
  resources :events, only: %i[] do
    get :filter_values, on: :collection
  end

  localized do
    resources :characters, except: %i[show create update]
    resources :events, only: %i[index show new create]

    root to: 'welcome#index'
  end
end
