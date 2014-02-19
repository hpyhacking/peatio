class IdentitiesController < ApplicationController
  before_filter :auth_anybody!

  def new
    @identity = env['omniauth.identity'] || Identity.new
  end
end
