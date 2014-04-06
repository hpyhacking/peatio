module Admin
  module Deposits
    class SatoshisController < ::Admin::Deposits::BaseController
      authorize_resource :class => '::Deposits::Satoshi'

      def index
        ::Deposits::Satoshi.all
      end
    end
  end
end
