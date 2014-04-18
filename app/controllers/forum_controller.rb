class ForumController < ApplicationController
  layout 'landing'

  def index
    render text: 'Please provide muut key and secret' and return unless muut_enabled?
  end
end
