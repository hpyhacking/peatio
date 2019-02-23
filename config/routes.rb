# encoding: UTF-8
# frozen_string_literal: true

Dir['app/models/deposits/**/*.rb'].each { |x| require_dependency x.split('/')[2..-1].join('/') }
Dir['app/models/withdraws/**/*.rb'].each { |x| require_dependency x.split('/')[2..-1].join('/') }

class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

Peatio::Application.routes.draw do

  draw :admin

  get '/swagger', to: 'swagger#index'

  mount API::Mount => API::Mount::PREFIX
end
