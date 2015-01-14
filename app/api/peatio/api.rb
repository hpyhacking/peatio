module Peatio
  class API < Grape::API
    mount APIv2::Mount
  end
end
