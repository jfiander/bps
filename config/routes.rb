Rails.application.routes.draw do
  root                             'public#index'

  devise_for :users, path: '', path_names: {sign_in: 'login', sign_out: 'logout'}
  as :user do
    get   '/profile',          to: 'devise/registrations#edit'
    patch '/profile',          to: 'devise/registrations#update'
    get   '/reset',            to: 'devise/passwords#new'
  end

  get     '/about',            to: 'public#about'
  get     '/join',             to: 'public#join'
  get     '/vsc',              to: 'public#vsc'
  get     '/education',        to: 'public#education'
  get     '/calendar',         to: 'public#calendar'
  get     '/events',           to: 'public#events'
  get     '/photos',           to: 'public#photos'
  get     '/civic',            to: 'public#civic'
  get     '/bridge',           to: 'public#bridge'
  get     '/history',          to: 'public#history'
  get     '/newsletter',       to: 'public#newsletter'
  get     '/store',            to: 'public#store'
  get     '/links',            to: 'public#links'

  get     '/members',          to: 'members#index'
  get     '/admin',            to: 'members#admin'

  get     '/users',            to: 'user#list'
  get     '/users/:id',        to: 'user#show',                    as: 'user'
  patch   '/users/:id/lock',   to: 'user#lock',                    as: 'lock_user'
  patch   '/users/:id/unlock', to: 'user#unlock',                  as: 'unlock_user'
  get     '/permit',           to: 'user#permissions_index'
  post    '/permit',           to: 'user#permissions_add'
  delete  '/permit',           to: 'user#permissions_remove'

  match   '/404',              to: 'errors#not_found',             via: :all
  match   '/500',              to: 'errors#internal_server_error', via: :all
end
