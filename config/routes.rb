# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:show, :edit, :update, :destroy] do
    member do
      get :favorites
      get :user_posts
      get :followings
      get :followers
    end
  end
  get 'boards/search'
  resources :boards do
    resource :favorites, only: [:create, :destroy]
  end
  resources :relationships, only: [:create, :destroy]
  root to: 'boards#index'
end
