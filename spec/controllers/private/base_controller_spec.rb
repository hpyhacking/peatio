require 'spec_helper'

describe Private::BaseController do

  context "auth_member filter" do

  end

  context "verify_two_factor! filter" do
    let!(:member) { create :activated_member }

    before do
      request.env["HTTP_REFERER"] = "/enter_your_otp"
      controller.session[:member_id] = member.id
      member.two_factor.refresh
    end

    controller(::Private::BaseController) do
      before_action :verify_two_factor!, only: :important

      def important; render text: 'you catch me!' end

      def trivial; render text: 'nothing' end
    end


    context "protect important action" do
      before do
        routes.draw { get "important" => "anonymous#important" }
      end
      it "renders if two factor is not activated" do
        get :important

        expect(response.body).to eq('you catch me!')
      end

      it "renders if provided correct otp" do
        member.two_factor.update_column :activated, true
        get :important, two_factor: { otp: member.two_factor.now }

        expect(response.body).to eq('you catch me!')
      end

      it "redirects if failed with wrong otp" do
        member.two_factor.update_column :activated, true

        get :important, two_factor: { otp: 123456 }
        expect(response).to redirect_to '/enter_your_otp'
      end

    end

    it "skip trivial action" do
      routes.draw { get "trivial" => "anonymous#trivial" }

      get :trivial
      expect(response.body).to eq('nothing')
    end
  end
end
