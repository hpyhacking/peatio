class WelcomeController < ApplicationController
  layout 'landing'
  include Concerns::DisableCabinetUI

  def index
  end
end
