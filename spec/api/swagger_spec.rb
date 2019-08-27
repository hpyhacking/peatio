# encoding: UTF-8
# frozen_string_literal: true

describe 'Swagger', type: :request do

  it "returns APIv2 swagger docs" do
    expect do
      get "/api/v2/swagger"
      expect(response).to have_http_status 200
    end.not_to raise_error
  end

  it "returns APIv2 management swagger docs" do
    expect do
      get "/api/v2/management/swagger"
      expect(response).to have_http_status 200
    end.not_to raise_error
  end

  it "returns APIv2 admin swagger docs" do
    expect do
      get "/api/v2/admin/swagger"
      expect(response).to have_http_status 200
    end.not_to raise_error
  end
end
