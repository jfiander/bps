# frozen_string_literal: true

Rails.application.routes.draw do
  root 'public#home'

  devise_for(
    :users,
    path: '',
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      new_user_password: 'reset'
    },
    controllers: {
      registrations: 'users/registrations',
      sessions: 'users/sessions',
      invitations: 'users/invitations'
    }
  )

  ### Profile management
  as :user do
    get   '/profile',      to: 'user#show'
    get   '/profile/edit', to: 'users/registrations#edit'
    put   '/profile/edit', to: 'users/registrations#update'
    get   '/reset',        to: 'devise/passwords#new'
  end

  ### Markdown pages
  get     '/home',         to: redirect('/')
  get     '/about',        to: 'public#about'
  get     '/join',         to: 'public#join'
  get     '/requirements', to: 'public#requirements'
  get     '/vsc',          to: 'public#vsc'
  get     '/education',    to: 'public#education'
  get     '/calendar',     to: 'public#calendar'
  get     '/civic',        to: 'public#civic'
  get     '/history',      to: 'public#history'
  get     '/links',        to: 'public#links'
  get     '/members',      to: 'members#members'
  get     '/welcome',      to: 'members#welcome'
  get     '/user_help',    to: 'members#user_help'

  ### Static pages
  get     '/refunds',       to: 'braintree#refunds'
  get     '/payment_terms', to: 'braintree#terms'

  ### Dynamic pages
  get     '/ranks',            to: 'members#ranks'
  get     '/auto_permissions', to: 'permissions#auto'

  ### Functional pages
  get     '/bridge',                    to: 'bridge#list'
  get     '/newsletter',                to: 'public#newsletter'
  get     '/store',                     to: 'public#store'
  get     '/photos',                    to: 'gallery#index'
  get     '/minutes',                   to: 'members#minutes'
  post    '/assign_photo',              to: 'user#assign_photo'
  get     '/apply',                     to: 'member_applications#new'
  get     '/applications',              to: 'member_applications#review'
  get     '/dues',                      to: 'members#dues'
  get     '/s3',                        to: 'links#s3'
  post    '/s3',                        to: 'links#s3'
  get     '/versions/:model/:id',       to: 'versions#show',      as: 'show_versions'
  get     '/versions/:model/:id/:a/:b', to: 'versions#diff',      as: 'diff_versions'
  post    '/versions/:model/:id/:a/:b', to: 'versions#diff'
  patch   '/versions/:model/:id/:a',    to: 'versions#revert',    as: 'revert_version'
  get     '/versions(/:model)',         to: 'versions#index',     as: 'versions'
  get     '/float_plan',                to: 'float_plan#new',     as: 'float_plan'
  post    '/float_plan',                to: 'float_plan#submit',  as: 'submit_float_plan'
  patch   '/float_plan',                to: 'float_plan#refresh', as: 'refresh_float_plan'
  get     '/float_plans',               to: 'float_plan#list'
  get     '/jumpstart',                 to: 'otw_trainings#public'
  post    '/jumpstart',                 to: 'otw_trainings#public_request'

  ### Functional page back-ends

  # Newsletter
  get     '/bilge/:year/:month',   to: 'public#get_bilge',          as: 'bilge'
  get     '/minutes/:year/:month', to: 'members#get_minutes',       as: 'get_minutes'
  get     '/excom/:year/:month',   to: 'members#get_minutes_excom', as: 'get_minutes_excom'
  post    '/bilge',                to: 'members#upload_bilge',      as: 'upload_bilge'

  # Registration
  put     '/register', to: 'public#register', as: 'public_register'
  post    '/register', to: 'public#register', as: 'long_register'

  # Minutes
  post    '/minutes',         to: 'members#upload_minutes',  as: 'upload_minutes'

  # Markdown page editors
  get     '/edit/:page_name', to: 'members#edit_markdown',   as: 'edit_page'
  patch   '/edit/:page_name', to: 'members#update_markdown', as: 'update_page'

  # User invitation
  put     '/invite/:id', to: 'user#invite', as: 'invite'
  put     '/invite_all', to: 'user#invite_all'

  # Markdown files and header images
  get     '/file',               to: 'file#new',            as: 'file'
  post    '/file/upload',        to: 'file#create',         as: 'upload_file'
  delete  '/file/:id/destroy',   to: 'file#destroy',        as: 'remove_file'
  get     '/header',             to: 'file#new_header',     as: 'header'
  post    '/header/upload',      to: 'file#create_header',  as: 'upload_header'
  delete  '/header/:id/destroy', to: 'file#destroy_header', as: 'remove_header'

  # Locations and Event Types
  %i[location event_type].each do |model|
    get     "/#{model}s",               to: "#{model}s#list",    as: "#{model}s"
    get     "/#{model}s/new",           to: "#{model}s#new",     as: "new_#{model}"
    post    "/#{model}s/create",        to: "#{model}s#create",  as: "create_#{model}"
    get     "/#{model}s/:id/edit",      to: "#{model}s#edit",    as: "edit_#{model}"
    patch   "/#{model}s/:id/update",    to: "#{model}s#update",  as: "update_#{model}"
    delete  "/#{model}s/:id/remove",    to: "#{model}s#remove",  as: "remove_#{model}"
    get     "/#{model}s/refresh(/:id)", to: "#{model}s#refresh", as: "refresh_#{model}s"
  end

  # Roster Historical Records
  namespace :roster do
    resource :award_recipients
    resource :past_commanders
  end

  # Photo Galleries
  post    '/album/new',       to: 'gallery#add_album',    as: 'new_album'
  get     '/album/:id',       to: 'gallery#show',         as: 'show_album'
  delete  '/album/:id',       to: 'gallery#remove_album', as: 'remove_album'
  post    '/album/photo',     to: 'gallery#upload_photo', as: 'upload_photo'
  delete  '/album/photo/:id', to: 'gallery#remove_photo', as: 'remove_photo'

  # Store
  get     '/store/new',         to: 'store#new',            as: 'new_store_item'
  post    '/store/create',      to: 'store#create',         as: 'create_store_item'
  patch   '/store/update',      to: 'store#update',         as: 'update_store_item'
  get     '/store/:id/edit',    to: 'store#edit',           as: 'edit_store_item'
  put     '/store/:id/request', to: 'members#request_item', as: 'request_store_item'
  patch   '/store/:id/fulfill', to: 'members#fulfill_item', as: 'fulfill_store_item'
  delete  '/store/:id/destroy', to: 'store#destroy',        as: 'destroy_store_item'

  # Editor auto-show state setters
  post    '/auto_show', to: 'user#auto_show', as: 'auto_show'
  post    '/auto_hide', to: 'user#auto_hide', as: 'auto_hide'

  # Member Applications
  put     '/apply',                   to: 'member_applications#apply',   as: 'submit_application'
  get     '/applied(/:token)',        to: 'member_applications#applied', as: 'applied'
  patch   '/approve_application/:id', to: 'member_applications#approve', as: 'approve_application'

  # Roster
  get  '/roster',                    to: 'members#roster',        as: 'roster'
  # get  '/update_roster',             to: 'members#update_roster', as: 'update_roster'
  # post '/update_roster',             to: 'members#upload_roster'
  get  '/roster/gen(/:orientation)', to: 'members#roster_gen',    as: 'roster_gen', defaults: { orientation: 'detailed' }

  # OTW Trainings
  get     '/otw',            to: 'otw_trainings#user'
  get     '/otw/requests',   to: 'otw_trainings#list_requests'
  get     '/otw/list',       to: 'otw_trainings#list'
  get     '/otw/new',        to: 'otw_trainings#new',          as: 'new_otw'
  post    '/otw/new',        to: 'otw_trainings#create',       as: 'create_otw'
  put     '/otw/:id',        to: 'otw_trainings#user_request', as: 'otw_request'
  get     '/otw/:id/edit',   to: 'otw_trainings#edit',         as: 'edit_otw'
  patch   '/otw/:id/edit',   to: 'otw_trainings#update',       as: 'update_otw'
  delete  '/otw/:id/remove', to: 'otw_trainings#destroy',      as: 'remove_otw'

  # Course Completions
  get     '/completions',     to: 'completions#list'
  get     '/completions/ytd', to: 'completions#ytd'

  [:course, :seminar, :event].each do |event_type|
    get     "/#{event_type}s",               to: "events/#{event_type}s#schedule"
    get     "/#{event_type}s/catalog",       to: "events/#{event_type}s#catalog",       as: "#{event_type}_catalog" unless event_type == :event
    get     "/#{event_type}s/registrations", to: "events/#{event_type}s#registrations", as: "#{event_type}_registrations"
    get     "/#{event_type}s/new",           to: "events/#{event_type}s#new",           as: "new_#{event_type}"
    post    "/#{event_type}s/create",        to: "events/#{event_type}s#create",        as: "create_#{event_type}"
    patch   "/#{event_type}s/update",        to: "events/#{event_type}s#update",        as: "update_#{event_type}"
    get     "/#{event_type}s/:id",           to: "events/#{event_type}s#show",          as: "show_#{event_type}"
    get     "/#{event_type}s/:id/copy",      to: "events/#{event_type}s#copy",          as: "copy_#{event_type}"
    get     "/#{event_type}s/:id/edit",      to: "events/#{event_type}s#edit",          as: "edit_#{event_type}"
    delete  "/#{event_type}s/:id/expire",    to: "events/#{event_type}s#expire",        as: "expire_#{event_type}"
    put     "/#{event_type}s/:id/remind",    to: "events/#{event_type}s#remind",        as: "remind_#{event_type}"
    put     "/#{event_type}s/:id/book",      to: "events/#{event_type}s#book",          as: "book_#{event_type}"
    delete  "/#{event_type}s/:id/unbook",    to: "events/#{event_type}s#unbook",        as: "unbook_#{event_type}"
  end

  ### User management

  # Profiles
  get     '/users',                 to: 'user#list'
  get     '/users/:id',             to: 'user#show',        as: 'user'
  get     '/users/:id/certificate', to: 'user#certificate', as: 'user_certificate'
  get     '/instructors',           to: 'user#instructors', as: 'instructors'
  post    '/instructors',           to: 'user#instructors'

  # Locking
  patch   '/users/:id/lock',   to: 'user#lock',   as: 'lock_user'
  patch   '/users/:id/unlock', to: 'user#unlock', as: 'unlock_user'

  # Permissions
  get     '/permit', to: 'permissions#index'
  post    '/permit', to: 'permissions#add'
  delete  '/permit', to: 'permissions#remove'

  # Bridge and committee management
  post    '/assign_bridge',                 to: 'bridge#assign_bridge'
  post    '/assign_committee',              to: 'bridge#assign_committee'
  delete  '/remove_committee/:id',          to: 'bridge#remove_committee',          as: 'remove_committee'
  post    '/assign_standing_committee',     to: 'bridge#assign_standing_committee'
  delete  '/remove_standing_committee/:id', to: 'bridge#remove_standing_committee', as: 'remove_standing_committee'

  # Registration
  put     '/register/:type/:id', to: 'user#register',            as: 'register'
  delete  '/register/:id',       to: 'user#cancel_registration', as: 'cancel_registration'

  # Request
  put     '/request/:id', to: 'user#request_schedule', as: 'request_schedule'

  # Import
  get     '/import', to: 'user#import', as: 'import_users'
  post    '/import', to: 'user#do_import'

  # Payments
  get     '/pay/:token',          to: 'braintree#index',      as: 'pay'
  get     '/please_pay(/:token)', to: 'braintree#ask_to_pay', as: 'ask_to_pay'
  post    '/checkout',            to: 'braintree#checkout'
  get     '/paid(/:token)',       to: 'braintree#done',       as: 'transaction_complete'

  ### Miscellaneous
  get     '/sitemap.xml',    to: 'sitemap#index',  as: 'sitemap', format: 'xml'
  get     '/robots.:format', to: 'sitemap#robots', as: 'robots'

  ### Error codes
  match   '/404', to: 'errors#not_found',             via: :all
  match   '/500', to: 'errors#internal_server_error', via: :all
end
