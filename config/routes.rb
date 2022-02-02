# frozen_string_literal: true

Rails.application.routes.draw do
  # default_url_options protocol: :https, host: ENV['HOST'] || 'localhost:3000'
  default_url_options only_path: true
  apipie
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root 'users#new'

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      namespace :dictionary do
        get :roles
        get :info_types
        get :fact_types
        get :relation_types
        get :relationship_types
        get :sex
      end
      resources :family_trees, only: [:index, :show, :create, :update, :destroy] do
        get :timeline,    on: :member
        get :calendar,    on: :member
        get :person_tree, on: :member
        post :rollback,   on: :member
        post :invite,     on: :member
        post :change_user_role, on: :member
      end
      resources :persons, only: [:show, :create, :update, :destroy] do
        resources :archives, only: [:create, :update, :destroy, :show]
        resources :photos,   only: [:create, :update, :destroy, :show]
        resources :facts,    only: [:create, :update, :destroy, :show]
        patch :info, on: :member
      end
      resources :relations, only: [:create, :update, :destroy]
      resources :relationships, only: [:create, :update, :destroy]
      resources :users, only: [:show] do
        post :registration, on: :collection
        post :registration_call, on: :collection
        post :callcheck, on: :collection
        post :login, on: :collection
        get :check, on: :collection
      end
    end
  end

  resources :family_trees
  resources :persons do
    get :graph, on: :member
  end
  resources :users, only: [:new, :show] do
    post :create_user, on: :collection
    get :welcome, on: :collection
  end
end
