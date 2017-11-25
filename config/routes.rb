Rails.application.routes.draw do
  root                               'public#index'

  devise_for :users, path: '',
    path_names: {sign_in: 'login', sign_out: 'logout'},
    controllers: {invitations: 'users/invitations', registrations: 'users/registrations'}

  as :user do
    get   '/profile/edit',       to: 'users/registrations#edit'
    put   '/profile/edit',       to: 'users/registrations#update'
    get   '/reset',              to: 'devise/passwords#new'
  end

  get     '/about',              to: 'public#about'
  get     '/join',               to: 'public#join'
  get     '/vsc',                to: 'public#vsc'
  get     '/education',          to: 'public#education'
  get     '/calendar',           to: 'public#calendar'
  get     '/photos',             to: 'public#photos'
  get     '/civic',              to: 'public#civic'
  get     '/bridge',             to: 'public#bridge'
  get     '/history',            to: 'public#history'
  get     '/newsletter',         to: 'public#newsletter'
  get     '/bilge/:year/:month', to: 'public#get_bilge',             as: 'bilge'
  get     '/store',              to: 'public#store'
  get     '/links',              to: 'public#links'

  get     '/members',            to: 'members#index'
  post    '/bilge',              to: 'members#upload_bilge'
  get     '/flags',              to: 'members#download_flags'

  [:course, :seminar, :event].each do |event_type|
    get     "/#{event_type}s",             to: 'public#events',                                   defaults: {type: event_type}
    get     "/#{event_type}s/new",         to: 'events#new',         as: "new_#{event_type}",     defaults: {type: event_type}
    get     "/#{event_type}s/copy/:id",    to: 'events#copy',        as: "copy_#{event_type}",    defaults: {type: event_type}
    post    "/#{event_type}s/create",      to: 'events#create',      as: "create_#{event_type}",  defaults: {type: event_type}
    get     "/#{event_type}s/edit/:id",    to: 'events#edit',        as: "edit_#{event_type}",    defaults: {type: event_type}
    patch   "/#{event_type}s/update",      to: 'events#update',      as: "update_#{event_type}",  defaults: {type: event_type}
    delete  "/#{event_type}s/destroy/:id", to: 'events#destroy',     as: "destroy_#{event_type}", defaults: {type: event_type}
  end

  get     '/users',              to: 'user#list'
  get     '/users/current',      to: 'user#current',                 as: 'current_user'
  get     '/users/:id',          to: 'user#show',                    as: 'user'
  patch   '/users/:id/lock',     to: 'user#lock',                    as: 'lock_user'
  patch   '/users/:id/unlock',   to: 'user#unlock',                  as: 'unlock_user'
  get     '/permit',             to: 'user#permissions_index'
  post    '/permit',             to: 'user#permissions_add'
  delete  '/permit',             to: 'user#permissions_remove'
  post    '/assign_bridge',      to: 'user#assign_bridge'
  post    '/assign_committee',   to: 'user#assign_committee'
  delete  '/remove_committee',   to: 'user#remove_committee'
  put     '/register/:type/:id', to: 'user#register',                as: 'register'

  match   '/404',                to: 'errors#not_found',             via: :all
  match   '/500',                to: 'errors#internal_server_error', via: :all
end
