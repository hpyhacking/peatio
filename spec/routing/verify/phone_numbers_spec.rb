require 'spec_helper'

describe "private" do
  describe "route for phone_numbers" do
    it "get /verify/phone_numbers/new to be routable" do
      expect(get("/verify/phone_numbers/new")).to be_routable
    end

    it "route /verify/phone_numbers/new to verify/phone_numbers#new" do
      expect(get("/verify/phone_numbers/new")).to route_to("verify/phone_numbers#new")
    end

    it "post /verify/phone_numbers to be routable" do
      expect(post("/verify/phone_numbers")).to be_routable
    end

    it "route /verify/phone_numbers to verify/phone_numbers" do
      expect(post("/verify/phone_numbers")).to route_to("verify/phone_numbers#create")
    end
  end
end
