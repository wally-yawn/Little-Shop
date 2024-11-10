Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      get '/merchants/find', to: 'merchants#find'
      get '/items/find_all', to: 'items#find_all'
      get '/items',     to: 'items#index'
      get '/items/:id', to: 'items#show'
      post '/items', to: 'items#create'
      patch '/items/:id', to: 'items#update'
      get "/merchants", to: "merchants#index"
      post "/merchants", to: "merchants#create"
      get "/merchants/:id", to: "merchants#show"
      patch "/merchants/:id", to: "merchants#update"
      delete "/merchants/:id", to: "merchants#destroy"
      get '/merchants/:merchant_id/customers', to: 'customers#index'
      get '/merchants/:merchant_id/customers/:id', to: 'customers#show'
      get '/merchants/:merchant_id/invoices', to: 'invoices#index'
      get '/invoices/:id', to: 'invoices#show'  
      get "/customers/:customer_id/invoices", to: 'invoices#index'
      get "/merchants/:id/items", to: 'items#index'
      get '/items/:item_id/merchant', to: "merchants#show"
      delete '/items/:id', to: 'items#destroy'
      
      get '/coupons/:id', to: 'coupons#show'
      get '/coupons', to: 'coupons#index'
      post '/coupons', to: 'coupons#create'
      get '/merchants/:merchant_id/coupons', to: 'merchant_coupons#index'
      patch '/coupons/:id/deactivate', to: 'coupons#deactivate'
    end
  end
end