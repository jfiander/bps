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
  get     '/courses',            to: 'public#courses'
  get     '/seminars',           to: 'public#seminars'
  get     '/calendar',           to: 'public#calendar'
  get     '/events',             to: 'public#events'
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
  get     '/courses/new',        to: 'events#new_event',             as: 'new_course',     defaults: {type: :course}
  post    '/courses/create',     to: 'events#create_event',          as: 'create_course',  defaults: {type: :course}
  get     '/seminars/new',       to: 'events#new_event',             as: 'new_seminar',    defaults: {type: :seminar}
  post    '/seminars/create',    to: 'events#create_event',          as: 'create_seminar', defaults: {type: :seminar}
  get     '/events/new',         to: 'events#new_event',             as: 'new_event',      defaults: {type: :event}
  post    '/events/create',      to: 'events#create_event',          as: 'create_event',   defaults: {type: :event}

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

  match   '/404',                to: 'errors#not_found',             via: :all
  match   '/500',                to: 'errors#internal_server_error', via: :all
end
