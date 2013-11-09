Localflows::Application.routes.draw do
  root 'flows#index'
  match 'auth/:provider/callback', to: "sessions#create", via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get]

 end
