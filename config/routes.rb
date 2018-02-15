Rails.application.routes.draw do
  root                               'public#home'

  devise_for :users, path: '',
    path_names: {sign_in: 'login', sign_out: 'logout'},
    controllers: {registrations: 'users/registrations', sessions: 'users/sessions', invitations: 'users/invitations'}

  # Profile management
  as :user do
    get   '/profile/edit',       to: 'users/registrations#edit'
    put   '/profile/edit',       to: 'users/registrations#update'
    get   '/reset',              to: 'devise/passwords#new'
  end

  # Static pages
  get     '/home',               to: redirect('/')
  get     '/about',              to: 'public#about'
  get     '/join',               to: 'public#join'
  get     '/requirements',       to: 'public#requirements'
  get     '/vsc',                to: 'public#vsc'
  get     '/education',          to: 'public#education'
  get     '/calendar',           to: 'public#calendar'
  get     '/civic',              to: 'public#civic'
  get     '/history',            to: 'public#history'
  get     '/links',              to: 'public#links'
  get     '/members',            to: 'members#members'
  get     '/welcome',            to: 'members#welcome'
  get     '/user_help',          to: 'members#user_help'
  get     '/auto_permissions',   to: 'members#auto_permissions'

  # Dynamic pages
  get     '/ranks',              to: 'members#ranks'

  # Functional pages
  get     '/bridge',             to: 'public#bridge'
  get     '/newsletter',         to: 'public#newsletter'
  get     '/store',              to: 'public#store'
  get     '/photos',             to: 'gallery#index'
  get     '/minutes',            to: 'members#minutes'

  # Functional page back-ends
  get     '/bilge/:year/:month',   to: 'public#get_bilge',           as: 'bilge'
  get     '/minutes/:year/:month', to: 'members#get_minutes',        as: 'get_minutes'
  get     '/excom/:year/:month',   to: 'members#get_minutes_excom',  as: 'get_minutes_excom'
  put     '/register',             to: 'public#register',            as: 'public_register'
  post    '/register',             to: 'public#register',            as: 'long_register'
  post    '/bilge',                to: 'members#upload_bilge',       as: 'upload_bilge'
  post    '/minutes',              to: 'members#upload_minutes',     as: 'upload_minutes'
  get     '/edit/:page_name',      to: 'members#edit_markdown',      as: 'edit_page'
  patch   '/edit/:page_name',      to: 'members#update_markdown'
  get     '/invite',               to: 'user#invite'
  get     '/invite_all',           to: 'user#invite_all'

  get     '/file',               to: 'file#new',                     as: 'file'
  post    '/file/upload',        to: 'file#create',                  as: 'upload_file'
  delete  '/file/:id/destroy',   to: 'file#destroy',                 as: 'remove_file'

  post    '/album/new',          to: 'gallery#add_album',            as: 'new_album'
  get     '/album/:id',          to: 'gallery#edit_album',           as: 'edit_album'
  delete  '/album/:id',          to: 'gallery#remove_album',         as: 'remove_album'
  post    '/album/photo',        to: 'gallery#upload_photo',         as: 'upload_photo'
  delete  '/album/photo/:id',    to: 'gallery#remove_photo',         as: 'remove_photo'

  get     '/store/new',          to: 'store#new',                    as: 'new_store_item'
  post    '/store/create',       to: 'store#create',                 as: 'create_store_item'
  patch   '/store/update',       to: 'store#update',                 as: 'update_store_item'
  get     '/store/:id/edit',     to: 'store#edit',                   as: 'edit_store_item'
  put     '/store/:id/request',  to: 'members#request_item',         as: 'request_store_item'
  patch   '/store/:id/fulfill',  to: 'members#fulfill_item',         as: 'fulfill_store_item'
  delete  '/store/:id/destroy',  to: 'store#destroy',                as: 'destroy_store_item'

  [:course, :seminar, :event].each do |event_type|
    get     "/#{event_type}s",             to: 'public#events',                                   defaults: {type: event_type}
    get     "/#{event_type}s/catalog",     to: 'public#catalog',     as: "#{event_type}_catalog", defaults: {type: event_type} unless event_type == :event
    get     "/#{event_type}s/new",         to: 'events#new',         as: "new_#{event_type}",     defaults: {type: event_type}
    post    "/#{event_type}s/create",      to: 'events#create',      as: "create_#{event_type}",  defaults: {type: event_type}
    patch   "/#{event_type}s/update",      to: 'events#update',      as: "update_#{event_type}",  defaults: {type: event_type}
    get     "/#{event_type}s/:id",         to: 'events#show',        as: "show_#{event_type}",    defaults: {type: event_type}
    get     "/#{event_type}s/:id/copy",    to: 'events#copy',        as: "copy_#{event_type}",    defaults: {type: event_type}
    get     "/#{event_type}s/:id/edit",    to: 'events#edit',        as: "edit_#{event_type}",    defaults: {type: event_type}
    delete  "/#{event_type}s/:id/expire",  to: 'events#expire',      as: "expire_#{event_type}",  defaults: {type: event_type}
  end

  # User management
  get     '/users',                         to: 'user#list'
  get     '/users/current',                 to: 'user#current',                   as: 'current_user'
  get     '/users/:id',                     to: 'user#show',                      as: 'user'
  patch   '/users/:id/lock',                to: 'user#lock',                      as: 'lock_user'
  patch   '/users/:id/unlock',              to: 'user#unlock',                    as: 'unlock_user'
  get     '/permit',                        to: 'user#permissions_index'
  post    '/permit',                        to: 'user#permissions_add'
  delete  '/permit',                        to: 'user#permissions_remove'
  post    '/assign_bridge',                 to: 'user#assign_bridge'
  post    '/assign_committee',              to: 'user#assign_committee'
  delete  '/remove_committee/:id',          to: 'user#remove_committee',          as: 'remove_committee'
  post    '/assign_standing_committee',     to: 'user#assign_standing_committee'
  delete  '/remove_standing_committee/:id', to: 'user#remove_standing_committee', as: 'remove_standing_committee'
  put     '/register/:type/:id',            to: 'user#register',                  as: 'register'
  delete  '/register/:id',                  to: 'user#cancel_registration',       as: 'cancel_registration'
  get     '/import',                        to: 'user#import',                    as: 'import_users'
  post    '/import',                        to: 'user#do_import'

  # Miscellaneous
  get     '/sitemap.xml',                   to: 'sitemap#index', format: 'xml',   as: 'sitemap'
  get     '/robots.:format',                to: 'sitemap#robots',                 as: 'robots'

  # Error codes
  match   '/404',                to: 'errors#not_found',             via: :all
  match   '/500',                to: 'errors#internal_server_error', via: :all
end
