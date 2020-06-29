require "sidekiq/web"
Rails.application.routes.draw do
  scope "(:locale)", locale: /vi|en/ do
    root "static_pages#home"

    devise_scope :user do
      get "/login", to: "devise/sessions#new", as: "login"
      post "/login", to: "devise/sessions#create"
      get "/register", to: "devise/registrations#new", as: "register"
      delete "/logout", to: "devise/sessions#destroy", as: "logout"
    end
    get "/search", to: "documents#search", as: "search"

    namespace :admin do
      resources :documents, only: %i(index edit update)
      resources :users, only: %i(index edit update) do
        collection do
          get "/export", to: "users#export"
          get "/export_status", to: "users#export_status"
          get "/export_download", to: "users#export_download"
        end
      end
      resources :categories, only: %i(index edit update new create)
      resources :histories, only: :index
    end

    resources :documents, only: %i(create show) do
        resources :comments, only: %i(new create delete)
    end
    resources :comments do
      resources :comments, only: %i(new create delete)
    end
    resources :downloads, only: :show
    resources :categories, only: %i(new create)
    resources :favorites, only: %i(create destroy)
    resources :account_activations, only: :edit
    devise_for :users
    resources :users, only: %i(show) do
      member do
        get :favorites
      end
    end
    authenticate :user, ->(user) { user.admin? } do
      mount Sidekiq::Web, at: "/sidekiq"
    end
  end
end
