require 'spec_helper'

module Authentications
  describe WeiboAccountsController do
    let(:member) { create(:member, email: nil, activated: false) }
    before { session[:member_id] = member.id }

    describe "DELETE destroy" do
      let!(:authentication) { create(:authentication, provider: 'weibo', member_id: member.id)}
      subject(:do_request) { delete :destroy}
      context "Only one authentication " do
        it "should not remove the authentication" do
          expect do
            do_request
          end.not_to change(Authentication, :count)
        end

        it "should tell user the reason" do
          do_request
          flash[:alert].should == t("authentications.weibo.destroy.last_auth_alert")
        end
      end

      context "More than one authentications" do
        let!(:auth_ideneity) { create(:authentication, provider: 'identity', member_id: member.id)}

        it "should delete the weibo authentication" do
          expect do
            do_request
          end.to change(Authentication, :count).by(-1)
        end

        it "should set the flash message" do
          do_request
          flash[:notice].should == t("authentications.weibo.destroy.unbind_success")
        end

      end

      it "should redirect user to settings_path" do
        do_request
        response.should redirect_to(settings_path)
      end
    end

  end
end
