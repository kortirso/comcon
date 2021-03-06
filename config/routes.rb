# frozen_string_literal: true

Rails.application.routes.draw do
  # mount PgHero::Engine, at: 'pghero'

  namespace :api do
    namespace :v1 do
      resources :game_item_categories, only: %i[index]
      resources :races, only: %i[index]
      resources :character_classes, only: %i[index]
      resources :worlds, only: %i[index]
      resources :guilds, only: %i[index show create update] do
        get :characters, on: :member
        post :kick_character, on: :member
        post :leave_character, on: :member
        get :search, on: :collection
        get :form_values, on: :collection
        get :characters_for_request, on: :member
        post :import_bank, on: :member
        get :bank, on: :member
      end
      resources :roles, only: %i[index]
      resources :dungeons, only: %i[index]
      resources :fractions, only: %i[index]
      resources :characters, only: %i[index show create update] do
        get :default_values, on: :collection
        get :search, on: :collection
        get :search_for_event, on: :collection
        post :upload_recipes, on: :member
      end
      resources :events, except: %i[index new] do
        get :subscribers, on: :member
        get :user_characters, on: :member
        get :event_form_values, on: :collection
        get :characters_without_subscribe, on: :member
      end
      resources :subscribes, only: %i[create update]
      resources :professions, only: %i[index]
      resources :recipes, only: %i[index show create update] do
        get :search, on: :collection
      end
      resources :guild_roles, only: %i[create update destroy]
      resources :craft, only: %i[] do
        get :filter_values, on: :collection
        get :search, on: :collection
      end
      resources :statics, only: %i[index show create update] do
        get :form_values, on: :collection
        get :members, on: :member
        get :subscribers, on: :member
        post :kick_character, on: :member
        post :leave_character, on: :member
        get :search, on: :collection
        get :characters_for_request, on: :member
      end
      resources :static_invites, only: %i[index create destroy] do
        post :approve, on: :member
        post :decline, on: :member
      end
      resources :static_members, only: %i[destroy]
      resources :notifications, only: %i[index]
      resources :deliveries, only: %i[create]
      resources :guild_invites, only: %i[index create destroy] do
        post :approve, on: :member
        post :decline, on: :member
      end
      resources :user_settings, only: %i[index] do
        patch :update_settings, on: :collection
        patch :update_password, on: :collection
      end
      resources :bank_requests, only: %i[index create destroy] do
        post :decline, on: :member
        post :approve, on: :member
      end
    end

    namespace :v2 do
      resources :worlds, only: %i[index]
      resources :recipes, only: %i[index]
      resources :subscribes, only: %i[destroy] do
        get :closest, on: :collection
      end
      resources :characters, only: %i[index] do
        patch :transfer, on: :member
        post :equipment, on: :member
      end
      resources :events, only: %i[index] do
        get :filter_values, on: :collection
        get :subscribers, on: :member
      end
      resources :activities, only: %i[index show create update]
      resources :user_token, only: %i[create]
    end
  end

  devise_for :users, skip: %i[session registration], controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  localized do
    devise_for :users, skip: :omniauth_callbacks, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

    resources :characters, except: %i[create update] do
      get :recipes, on: :member
      post :update_recipes, on: :member
      get :transfer, on: :member
    end
    resources :events, only: %i[index show new edit]
    resources :worlds, except: %i[show]
    resources :users, except: %i[show new create] do
      get :restore_password, on: :collection, as: :restore_password
      post :reset_password, on: :collection
      get :new_password, on: :collection, as: :new_password
      patch :change_password, on: :collection
    end
    resources :recipes, only: %i[index new edit destroy]
    resources :guilds, only: %i[index show new edit] do
      get :activities, on: :member
      get :management, on: :member
      get :statics, on: :member
      get :notifications, on: :member
      get :bank, on: :member
      get :roster, on: :member
    end
    resources :craft, only: %i[index]
    resources :statics, except: %i[create update] do
      get :management, on: :member
      get :search, on: :collection
    end
    resources :static_invites, only: %i[] do
      get :find, on: :collection
      get :approve, on: :member
      get :decline, on: :member
    end
    resources :deliveries, only: %i[new destroy]
    resources :activities, only: %i[index new edit destroy]
    resources :guild_invites, only: %i[] do
      get :find, on: :collection
    end
    resources :settings, only: %i[index] do
      get :password, on: :collection
      get :external_services, on: :collection
      get :notifications, on: :collection
    end
    resources :email_confirmations, only: %i[index]

    get :donate, to: 'welcome#donate', as: :donate
    get :privacy, to: 'welcome#privacy', as: :privacy

    root to: 'welcome#index'
  end
end
