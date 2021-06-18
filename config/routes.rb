Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "email_validator#index"
  get '/email_validator' => 'email_validator#index'
  post '/email_validator' => 'email_validator#search'

end
