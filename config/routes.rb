Rails.application.routes.draw do
  get '/' => "rooms#index"
  get '/autoReload' => "posts#autoReload"
  get '/new' => "posts#new"
  post '/create' => "posts#create"
  get '/superuser' => "posts#index"
  get '/guide' => "rooms#guide"

  get "/delete/:id" => "posts#delete"
  post '/img' => "posts#img"

  get '/rooms' => "rooms#index"
  get '/rooms/new' => "rooms#new"
  post '/rooms/create' => "rooms#create"
  get '/rooms/:id' => "rooms#timeline"
  get '/rooms/:id/lockRoom' => "rooms#lock_room"
  get '/rooms/save_location' => "rooms#save_location"

  get "project/change_session_year"
  get '*path', controller: 'application', action: 'render_404'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
