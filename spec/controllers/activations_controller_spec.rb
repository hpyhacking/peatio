require 'spec_helper'

module Private
  describe ActivationsController do
    it "new activation when you are not login" do
      get :new
      flash[:notice].should_not match(/missing/)
    end
  end
end
