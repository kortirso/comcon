Rails.application.routes.draw do
  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

  namespace :api do
    namespace :v1 do
      resources :races, only: %i[index]
      resources :character_classes, only: %i[index]
      resources :worlds, only: %i[index]
      resources :guilds, only: %i[index] do
        get :characters, on: :member
      end
      resources :roles, only: %i[index]
      resources :dungeons, only: %i[index]
      resources :fractions, only: %i[index]
      resources :characters, only: %i[show create update] do
        get :default_values, on: :collection
      end
      resources :events, only: %i[index show] do
        get :filter_values, on: :collection
      end
      resources :subscribes, only: %i[create update]
      resources :professions, only: %i[index]
      resources :recipes, only: %i[index show create update]
      resources :guild_roles, only: %i[create update destroy]
    end
  end

  localized do
    resources :characters, except: %i[show create update] do
      get :recipes, on: :member
      post :update_recipes, on: :member
    end
    resources :events, only: %i[index show new create]
    resources :worlds, except: %i[show]
    resources :users, except: %i[show new create]
    resources :recipes, only: %i[index new edit destroy]
    resources :guilds, only: %i[index show]

    root to: 'welcome#index'
  end
end
