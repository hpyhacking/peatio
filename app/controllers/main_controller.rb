# encoding: UTF-8
# frozen_string_literal: true

class MainController < ApplicationController
  layout 'landing'
  include Concerns::DisableCabinetUI

  def index
  end
end
