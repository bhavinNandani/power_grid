Rails.application.routes.draw do
  root to: "users#index"
  resources :posts
  
  get "examples/simple", to: "examples#simple"
  get "examples/complex", to: "examples#complex"
  get "examples/dashboard", to: "examples#dashboard"
end
