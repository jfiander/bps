Rails.application.routes.draw do
  root                'main#index'

  devise_for :users, path: '', path_names: {sign_in: 'login', sign_out: 'logout'}

  get '/members', to: 'main#members'

  get '/admin', to: 'main#admin'

  get '/*path',   to: redirect('/') unless Rails.env.development?
end
