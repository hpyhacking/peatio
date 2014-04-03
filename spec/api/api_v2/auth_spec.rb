require 'spec_helper'

describe APIv2::Auth do

  include APIv2::Auth

  context '#generate_access_key' do
    it "should be a string longer than 40 characters" do
      generate_access_key.should match(/^[a-zA-Z0-9\-_]{40}$/)
    end
  end

  context '#generate_secret_key' do
    it "should be a string longer than 40 characters" do
      generate_secret_key.should match(/^[a-zA-Z0-9\-_]{40}$/)
    end
  end

end
