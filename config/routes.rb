Rails.application.routes.draw do
  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

  resources :worlds, except: %i[show]
  resources :subscribes, only: %i[create update]

  localized do
    resources :characters, except: %i[show]
    resources :events, only: %i[index show new create]

    root to: 'welcome#index'
  end
end
