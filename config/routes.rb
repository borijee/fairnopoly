#
#
# == License:
# Fairnopoly - Fairnopoly is an open-source online marketplace.
# Copyright (C) 2013 Fairnopoly eG
#
# This file is part of Fairnopoly.
#
# Fairnopoly is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Fairnopoly is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Fairnopoly.  If not, see <http://www.gnu.org/licenses/>.
#
Fairnopoly::Application.routes.draw do

  mount Nkss::Engine => '/styleguides' if Rails.env.development? || Rails.env.staging?
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  concern :heartable do
    resources :hearts, only: [:create, :destroy]
  end

  concern :commentable do
    resources :comments, only: [:create, :destroy, :index]
  end

  namespace :admin do
    resources :article
  end

  resources :article_templates, except: [:show, :index]

  resources :mass_uploads, only: [:new, :create, :show, :update] do
    collection do
      get 'image_errors'
    end
  end

  get 'exports/show'

  resources :contents

  devise_for :user, controllers: { registrations: 'registrations', sessions: 'sessions' }

  namespace :toolbox do
    get 'session_expired', as: 'session_expired', constraints: {format: 'json'} # JSON info about session expiration. Might be moved to a custom controller at some point.
    get 'confirm', constraints: {format: 'js'}
    get 'rss'
    get 'notice/:id', action: 'notice', as: 'notice'
    get 'reload', as: 'reload'
    get 'contact', as: 'contact'
    patch 'reindex/:article_id', action: 'reindex', as: 'reindex'
    get 'healthcheck'
    get 'newsletter_status', as: 'newsletter_status', constraints: {format: 'json'}
  end

  namespace :statistics do
    get 'general'
    get 'category_sales'
  end

  namespace :bank_details do
    get 'check', constraints: {format: 'json'}
    get 'get_bank_name', constraints: {format: 'json'}
    get 'check_iban', constraints: {format: 'json'}
    get 'check_bic', constraints: {format: 'json'}
  end

  resources :articles, concerns: [:commentable] do
    member do
      get 'report'
    end
    collection do
      get 'autocomplete'
    end
  end


  resources :carts, only: [:show,:edit,:update]

  resources :line_items, only: [:create,:update,:destroy]

  resources :line_item_groups, only: [:show] do
    resources :payments, only: [:create, :show]
  end
  match '/paypal/ipn_notification' => PaypalIpn, as: 'ipn_notification', via: [:get, :post]

  get '/transactions/:id', to: 'business_transactions#show', as: 'business_transaction'

  resources :business_transactions, only: [:show] do
    resources :refunds, only: [ :new, :create ]
  end

  get 'welcome/reconfirm_terms'
  post 'welcome/reconfirm_terms'

  get 'welcome/index'
  get 'mitunsgehen', to: 'welcome#index'

  get 'feed', to: 'welcome#feed', constraints: {format: 'rss'}

  resources :feedbacks, only: [:create,:new]

  #the user routes

  resources :users, :only => [:show] do
    resources :addresses, except: [:index, :show]
    resources :libraries, :except => [:new,:edit]
    resources :library_elements, only: [:create, :destroy]
    resources :ratings, :only => [:create, :index] do
      get '/:line_item_group_id', to: 'ratings#new', as: 'line_item_group', on: :new
    end
    member do
      get 'profile'
    end
  end

  # library routes
  resources :libraries, only: [:index, :show],
                        concerns: [:heartable, :commentable] do
    patch 'admin_audit', on: :member

    collection do
      post 'admin_add', as: 'admin_add_to'
      delete 'admin_remove/:article_id/:exhibition_name', action: 'admin_remove', as: 'admin_remove_from'

    end
  end

  # special library #index routes
  get 'trending_libraries', to: 'libraries#index', defaults: { mode: 'trending' }
  get 'new_libraries', to: 'libraries#index', defaults: { mode: 'new' }
  get 'myfavorite_libraries', to: 'libraries#index', defaults: { mode: 'myfavorite' }


  # categories routes
  resources :categories, only: [:index,:show] do
    member do
      get 'select_category'
    end
    collection do
      get 'id_index', to: 'categories#id_index'
    end
  end

  post '/remote_validations/:model/:field/:value', to: 'remote_validations#create', as: 'remote_validation', constraints: {format: 'json'}

  root :to => 'welcome#index' # Workaround for double root https://github.com/gregbell/active_admin/issues/2049

  require 'sidekiq/web'
  require 'sidetiq/web'

  constraint = lambda { |request| request.env['warden'].authenticate? and
                      request.env['warden'].user.admin?}

  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end


  # TinyCMS Routes Catchup
  scope constraints: lambda {|request|
    request.params[:id] && !['assets','system','admin','public','favicon.ico', 'favicon'].any?{|url| request.params[:id].match(/^#{url}/)}
  } do
    get '/*id' => 'contents#show'
  end
end
