module Admin
  module Deposits
    class DuffsController < ::Admin::Deposits::BaseController
      load_and_authorize_resource class: '::Deposits::Duff'

      def index
        @duffs = @duffs.includes(:member)
                       .where('created_at > ?', 1.day.ago)
                       .order('id DESC')
                       .page(params[:page]).per(20)
      end

      def update
        @duff.accept! if @duff.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
