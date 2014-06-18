class ForumController < ApplicationController
  layout 'landing'

  def index
    render text: 'Please provide muut key and secret' and return unless muut_enabled?
    if current_user.try(:display_name).blank?
      redirect_to edit_member_path, notice: t('.notice.display_name') and return
    end
  end
end
