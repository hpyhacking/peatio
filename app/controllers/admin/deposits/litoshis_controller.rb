module Admin
  module Deposits
    class LitoshisController < ::Admin::Deposits::BaseController
      load_and_authorize_resource class: '::Deposits::Litoshi'

      def index
        @litoshis = @litoshis.
                       includes(:member).
                       where('created_at > ?', DateTime.now.ago(60 * 60 * 24 * 365)).
                       order('id DESC').
                       page(params[:page]).
                       per(20)
      end

      def update
        @litoshi.accept! if @litoshi.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
