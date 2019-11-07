Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :races, only: %i[index]
      resources :character_classes, only: %i[index]
      resources :worlds, only: %i[index]
      resources :guilds, only: %i[index] do
        get :characters, on: :member
        post :kick_character, on: :member
        post :leave_character, on: :member
      end
      resources :roles, only: %i[index]
      resources :dungeons, only: %i[index]
      resources :fractions, only: %i[index]
      resources :characters, only: %i[show create update] do
        get :default_values, on: :collection
        get :search, on: :collection
      end
      resources :events, except: %i[new edit] do
        get :subscribers, on: :member
        get :filter_values, on: :collection
        get :event_form_values, on: :collection
      end
      resources :subscribes, only: %i[create update]
      resources :professions, only: %i[index]
      resources :recipes, only: %i[index show create update]
      resources :guild_roles, only: %i[create update destroy]
      resources :craft, only: %i[] do
        get :filter_values, on: :collection
        get :search, on: :collection
      end
      resources :statics, only: %i[show create update] do
        get :form_values, on: :collection
        get :members, on: :member
      end
      resources :static_invites, only: %i[create destroy]
      resources :static_members, only: %i[destroy]
      resources :notifications, only: %i[index]
      resources :deliveries, only: %i[create]
      resources :guild_invites, only: %i[create]
    end
  end

  localized do
    devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

    resources :characters, except: %i[show create update] do
      get :recipes, on: :member
      post :update_recipes, on: :member
    end
    resources :events, only: %i[index show new edit]
    resources :worlds, except: %i[show]
    resources :users, except: %i[show new create]
    resources :recipes, only: %i[index new edit destroy]
    resources :guilds, only: %i[index show] do
      get :management, on: :member
    end
    resources :craft, only: %i[index]
    resources :statics, except: %i[create update] do
      get :management, on: :member
    end
    resources :static_invites, only: %i[] do
      get :approve, on: :member
      get :decline, on: :member
    end
    resources :deliveries, only: %i[new destroy]
    resources :guild_invites, only: %i[new]

    root to: 'welcome#index'
  end
end
