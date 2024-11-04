Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index

  get '/api/v1/items',     to: 'api/v1/items#index'
  get '/api/v1/items/:id', to: 'api/v1/items#show'

  get "/api/v1/merchants", to: "api/v1/merchants#index"
  post "/api/v1/merchants", to: "api/v1/merchants#create"
  get "/api/v1/merchants/:id", to: "api/v1/merchants#show"
  patch "/api/v1/merchants/:id", to: "api/v1/merchants#update"

  delete "/api/v1/merchants/:id", to: "api/v1/merchants#destroy"


  get '/api/v1/merchants/:merchant_id/customers', to: 'api/v1/customers#index'
  get '/api/v1/merchants/:merchant_id/customers/:id', to: 'api/v1/customers#show'

  get '/api/v1/merchants/:merchant_id/invoices', to: 'api/v1/invoices#index'
  post '/api/v1/merchants/:merchant_id/invoices', to: 'api/v1/invoices#create'
  get '/api/v1/invoices/:id', to: 'api/v1/invoices#show'  
  get "/api/v1/customers/:customer_id/invoices", to: 'api/v1/invoices#index'
  get "/api/v1/merchants/:id/items", to: 'api/v1/items#index'

end
