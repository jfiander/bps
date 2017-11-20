Rails.application.routes.draw do
  root                'main#index'

  devise_for :users

  get '/members', to: 'main#members'

  get '/*path',   to: redirect('/') unless Rails.env.development?
end
