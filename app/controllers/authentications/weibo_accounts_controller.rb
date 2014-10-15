module Authentications
  class WeiboAccountsController < ApplicationController
    before_action :auth_member!

    def destroy
      if current_user.authentications.count <= 1
        flash[:alert] = t("authentications.weibo.destroy.last_auth_alert")
      else
        if current_user.remove_auth('weibo')
          flash[:notice] = t("authentications.weibo.destroy.unbind_success")
        end
      end
      redirect_to settings_path
    end
  end
end
