# frozen_string_literal: true

Peatio::Application.routes.draw do

  get '/swagger', to: 'swagger#index'

  mount API::Mount => API::Mount::PREFIX
end
