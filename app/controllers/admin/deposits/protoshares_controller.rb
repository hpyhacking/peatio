module Admin
  module Deposits
    class ProtosharesController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Protoshare'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @protoshares = @protoshares.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC')
      end

      def update
        @protoshare.accept! if @protoshare.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
