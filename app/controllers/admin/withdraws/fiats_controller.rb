# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/withdraws/base_controller'

module Admin
  module Withdraws
    class FiatsController < BaseController
      before_action :find_withdraw, only: [:show, :update, :destroy]

      def index
        case params.fetch(:state, 'all')
        when 'all'
          @all_withdraws = all_withdraws
        when 'latest'
          @latest_withdraws = latest_withdraws
      end

      def show; end

      def update
        @withdraw.transaction do
          @withdraw.accept!
          @withdraw.process!
          @withdraw.dispatch!
          @withdraw.success!
        end
        redirect_to :back, notice: 'Withdraw successfully updated!'
      end

      def destroy
        @withdraw.reject!
        redirect_to :back, notice: 'Withdraw successfully destroyed!'
      end
    end
  end
end
