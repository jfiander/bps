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

  devise_scope :user do
    get    '/users/:id/edit',     to: 'users/registrations#admin_edit',   as: 'admin_edit'
    put    '/users/:id',          to: 'users/registrations#admin_update', as: 'admin_update'
  end

  ### Short URLs
  get     '/e/:slug',         to: 'events/events#slug',         as: 'event_slug'
  get     '/a/:id',           to: 'public#announcement_direct', as: 'short_announcement'
  get     '/b/:year/:month',  to: 'public#bilge',               as: 'short_bilge'
  get     '/m/:year/:month',  to: 'members#find_minutes',       as: 'short_minutes'
  get     '/ex/:year/:month', to: 'members#find_minutes',       as: 'short_excom', defaults: { minutes_excom: true }

  ### Profile management
  as :user do
    get    '/profile',            to: 'user#show'
    get    '/profile/edit',       to: 'users/registrations#edit'
    put    '/profile/edit',       to: 'users/registrations#update'
    get    '/reset',              to: 'devise/passwords#new'

    get    '/profile/tokens',     to: 'user#tokens'
    delete '/profile/tokens/:id', to: 'user#revoke_token', as: 'revoke_token'
  end

  ### Markdown pages
  %i[
    home about join requirements vsc education calendar civic history links
    members welcome user_help
  ].each do |md|
    get   "/#{md}",      to: "public##{md}", as: md,    defaults: { page_name: md } unless md.in?(%i[home members user_help welcome])
    get   "/#{md}/edit", to: 'members#edit_markdown',   defaults: { page_name: md }
    patch "/#{md}/edit", to: 'members#update_markdown', defaults: { page_name: md }
  end

  get     '/home',            to: redirect('/')
  get     '/members',         to: 'members#members'
  get     '/user_help',       to: 'members#user_help'
  get     '/welcome',         to: 'members#welcome'
  get     '/edit/:page_name', to: 'members#edit_markdown',   as: 'edit_page'
  patch   '/edit/:page_name', to: 'members#update_markdown', as: 'update_page'

  ### Static pages
  get     '/refunds',        to: 'braintree#refunds'
  get     '/payment_terms',  to: 'braintree#terms'
  get     '/flags',          to: 'flags#flags'
  get     '/flags/national', to: 'flags#national'
  get     '/tridents',       to: 'flags#tridents'
  get     '/intersections',  to: 'flags#intersections'
  get     '/complete',       to: 'public#complete'
  get     '/cancelled',      to: 'public#cancelled'

  ### Pre-loaded pages
  get     '/ranks',            to: 'members#ranks'
  get     '/auto_permissions', to: 'permissions#auto'

  ### Functional pages
  get     '/bridge', to: 'bridge#list'
  get     '/store',  to: 'public#store'

  # Photo gallery
  get     '/photos',       to: 'gallery#index'
  post    '/assign_photo', to: 'user#assign_photo'

  # Membership
  get     '/apply',        to: 'member_applications#new'
  get     '/applications', to: 'member_applications#review'
  get     '/dues',         to: 'members#dues'

  # Float plans
  get     '/float_plan',  to: 'float_plan#new',     as: 'float_plan'
  post    '/float_plan',  to: 'float_plan#submit',  as: 'submit_float_plan'
  patch   '/float_plan',  to: 'float_plan#refresh', as: 'refresh_float_plan'
  get     '/float_plans', to: 'float_plan#list'

  # Admin utilities
  namespace :admin do
    # S3 Link Generator
    get    '/s3',                        to: 'links#s3'
    post   '/s3',                        to: 'links#s3'

    # Versions
    get    '/versions/:model/:id',       to: 'versions#show',   as: 'show_versions'
    get    '/versions/:model/:id/:a/:b', to: 'versions#diff',   as: 'diff_versions'
    post   '/versions/:model/:id/:a/:b', to: 'versions#diff'
    patch  '/versions/:model/:id/:a',    to: 'versions#revert', as: 'revert_version'
    get    '/versions(/:model)',         to: 'versions#index',  as: 'versions'

    # Logo Generator
    get    '/logo',                      to: 'logos#logo'

    # Promo Codes
    get    '/promo_codes',               to: 'promo_codes#list'
    get    '/promo_codes/new',           to: 'promo_codes#new',      as: 'new_promo_code'
    put    '/promo_codes/new',           to: 'promo_codes#create',   as: 'create_promo_code'
    patch  '/promo_codes/:id/activate',  to: 'promo_codes#activate', as: 'activate_promo_code'
    delete '/promo_codes/:id/expire',    to: 'promo_codes#expire',   as: 'expire_promo_code'

    # Send Message
    get    '/message',                   to: 'sms#new', as: 'message'
    post   '/message',                   to: 'sms#send_message'

    # Generic Payments
    get    '/generic_payments',          to: 'generic_payments#index'
    get    '/generic_payments/new',      to: 'generic_payments#new'
    post   '/generic_payments',          to: 'generic_payments#create'
  end

  # Newsletter
  get     '/newsletter',         to: 'public#newsletter'
  get     '/bilge/:year/:month', to: 'public#bilge',         as: 'bilge'
  post    '/bilge',              to: 'members#upload_bilge', as: 'upload_bilge'
  get     '/bilge(/:year)',      to: redirect('/newsletter')

  # Announcements
  get     '/announcement/:id', to: 'public#announcement_direct',  as: 'announcement'
  post    '/announcement',     to: 'members#upload_announcement', as: 'upload_announcement'
  delete  '/announcement/:id', to: 'members#remove_announcement', as: 'remove_announcement'
  get     '/announcement',     to: redirect('/newsletter')
  get     '/announcements',    to: redirect('/newsletter')

  # Minutes
  get     '/minutes',              to: 'members#minutes'
  post    '/minutes',              to: 'members#upload_minutes', as: 'upload_minutes'
  get     '/minutes/:year/:month', to: 'members#find_minutes',   as: 'get_minutes'
  get     '/excom/:year/:month',   to: 'members#find_minutes',   as: 'get_minutes_excom', defaults: { excom: 'true' }
  get     '/minutes(/:year)', to: redirect('/minutes')

  # Registration
  put     '/register',        to: 'public#register', as: 'public_register'
  post    '/register',        to: 'public#register', as: 'long_register'

  # Subscriptions
  post    '/subscribe/:id',   to: 'members#subscribe',   as: 'subscribe'
  post    '/unsubscribe/:id', to: 'members#unsubscribe', as: 'unsubscribe'

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
    resource :archive_files
  end

  # Photo Galleries
  post    '/album/new',       to: 'gallery#add_album',    as: 'new_album'
  get     '/album/:id',       to: 'gallery#show',         as: 'show_album'
  delete  '/album/:id',       to: 'gallery#remove_album', as: 'remove_album'
  post    '/album/photo',     to: 'gallery#upload_photo', as: 'upload_photo'
  delete  '/album/photo/:id', to: 'gallery#remove_photo', as: 'remove_photo'

  # Editor auto-show state setters
  post    '/auto_show', to: 'user#auto_show', as: 'auto_show'
  post    '/auto_hide', to: 'user#auto_hide', as: 'auto_hide'

  # Member Applications
  put     '/apply',                   to: 'member_applications#apply',   as: 'submit_application'
  get     '/applied(/:token)',        to: 'member_applications#applied', as: 'applied'
  patch   '/approve_application/:id', to: 'member_applications#approve', as: 'approve_application'

  # Roster
  get     '/roster',                    to: 'members#roster',        as: 'roster'
  # get  '/update_roster',             to: 'members#update_roster', as: 'update_roster'
  # post '/update_roster',             to: 'members#upload_roster'
  get     '/roster/gen(/:orientation)', to: 'members#roster_gen',    as: 'roster_gen', defaults: { orientation: 'detailed' }

  # OTW Trainings
  get     '/otw',                to: 'otw_trainings#user'
  get     '/otw/progress(/:id)', to: 'otw_trainings#user_progress', as: 'otw_progress'
  get     '/otw/requests',       to: 'otw_trainings#list_requests'
  get     '/otw/list',           to: 'otw_trainings#list'
  get     '/otw/new',            to: 'otw_trainings#new',           as: 'new_otw'
  post    '/otw/new',            to: 'otw_trainings#create',        as: 'create_otw'
  put     '/otw/:id',            to: 'otw_trainings#user_request',  as: 'otw_request'
  get     '/otw/:id/edit',       to: 'otw_trainings#edit',          as: 'edit_otw'
  patch   '/otw/:id/edit',       to: 'otw_trainings#update',        as: 'update_otw'
  delete  '/otw/:id/remove',     to: 'otw_trainings#destroy',       as: 'remove_otw'

  # On-the-Water Training
  get     '/jumpstart', to: 'otw_trainings#public'
  post    '/jumpstart', to: 'otw_trainings#public_request'

  # Members Available for On-the-Water Training
  get     '/jumpstart/available', to: 'otw_trainings#available'
  get     '/vsc/available',       to: 'members#vse'

  # Course Completions
  get     '/completions',      to: 'completions#list'
  get     '/completions/ytd',  to: 'completions#ytd'
  get     '/completions/:year', to: 'completions#year'

  # Birthdays
  get    '/birthdays(/:month)',        to: 'birthdays#birthdays',  as: 'birthdays'
  post   '/birthdays(/:month)',        to: 'birthdays#birthdays'

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
    delete  "/#{event_type}s/:id/archive",   to: "events/#{event_type}s#archive",       as: "archive_#{event_type}"
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
  get     '/permit',            to: 'permissions#index'
  post    '/permit',            to: 'permissions#add'
  delete  '/permit/:permit_id', to: 'permissions#remove', as: 'remove_permit'

  # Bridge and committee management
  post    '/assign_bridge',                 to: 'bridge#assign_bridge'
  post    '/assign_committee',              to: 'bridge#assign_committee'
  delete  '/remove_committee/:id',          to: 'bridge#remove_committee',          as: 'remove_committee'
  post    '/assign_standing_committee',     to: 'bridge#assign_standing_committee'
  delete  '/remove_standing_committee/:id', to: 'bridge#remove_standing_committee', as: 'remove_standing_committee'

  # Registration
  patch   '/register/add/:id',      to: 'user#add_registrants',     as: 'add_registrants'
  put     '/register/:id',          to: 'user#register',            as: 'register'
  delete  '/register/:id',          to: 'user#cancel_registration', as: 'cancel_registration'
  get     '/override_cost/:token',  to: 'user#override_cost',       as: 'override_cost'
  patch   '/override_cost/:token',  to: 'user#set_override_cost',   as: 'set_override_cost'
  get     '/pay_advance/:token',    to: 'user#collect_payment',     as: 'modal_registration_pay'
  patch   '/refunded/:token',       to: 'user#refunded_payment',    as: 'refunded'

  # Request
  put     '/request/:id', to: 'user#request_schedule', as: 'request_schedule'

  # Import
  get     '/import',                  to: 'user#import',                  as: 'import_users'
  post    '/import',                  to: 'user#do_import'
  post    '/import/automatic',        to: 'user#automatic_update',        as: 'automatic_update'
  post    '/import/automatic/dryrun', to: 'user#automatic_update_dryrun', as: 'automatic_update_dryrun'

  # Payments
  get     '/pay/:token',            to: 'braintree#index',      as: 'pay'
  get     '/pay/:token(/:code)',    to: 'braintree#set_promo',  as: 'set_promo_code'
  get     '/please_pay(/:token)',   to: 'braintree#ask_to_pay', as: 'ask_to_pay'
  post    '/checkout',              to: 'braintree#checkout'
  get     '/paid(/:token)',         to: 'braintree#done',       as: 'transaction_complete'
  get     '/paid_in_person/:token', to: 'user#paid_in_person',  as: 'paid_in_person'
  get     '/receipts',              to: 'user#receipts'
  get     '/receipts/:token',       to: 'user#receipt',         as: 'receipt'

  # Award Nominations
  get     '/nominate', to: 'members#nominations'
  put     '/nominate', to: 'members#nominate'

  ### API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post '/login',               to: 'auth#login'
      post '/verify_user',         to: 'user_verify#verify'
      post '/update',              to: 'update#automatic_update'
      post '/update/queue',        to: 'update#queue_update'
      post '/update/queue/dryrun', to: 'update#queue_dryrun'
    end
  end

  ### Miscellaneous
  get     '/sitemap.xml',    to: 'sitemap#index',  as: 'sitemap', format: 'xml'
  get     '/robots.:format', to: 'sitemap#robots', as: 'robots'

  ### Error codes
  match   '/404', to: 'errors#not_found',             via: :all
  match   '/406', to: 'errors#not_acceptable',        via: :all
  match   '/500', to: 'errors#internal_server_error', via: :all

  ### Reroutes
  get     '/excom',          to: 'reroute#excom'
  get     '/member_meeting', to: 'reroute#member_meeting'
end
