# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/deposits/base_controller'

module Admin
  module Deposits
    class FiatsController < BaseController
      def index
        case params.fetch(:state, 'all')
        when 'all'
          @all_deposits = all_deposits
        when 'latest'
          @latest_deposits = latest_deposits
        end
      end

      def new
        @deposit = ::Deposits::Fiat.new
      end

      def show
        @deposit = ::Deposits::Fiat.where(currency: currency).find(params[:id])
      end

      def create
        @deposit = ::Deposits::Fiat.new(deposit_params)
        if @deposit.save
          redirect_to admin_deposit_index_url(params[:currency])
        else
          flash[:alert] = @deposit.errors.full_messages.first
          render :new
        end
      end

      def update
        @deposit = ::Deposits::Fiat.where(currency: currency).find(params[:id])
        case params.fetch(:commit)
        when 'Accept'
          @deposit.charge!
          flash.keep[:notice] = "The recharge have been successful."
        when 'Reject'
          @deposit.reject!
        end
        @deposit.reload
        render :show
      end

    private
      def deposit_params
        params.require(:deposits_fiat).slice(:uid, :amount)
              .merge(currency: currency)
              .permit!
      end
    end
  end
end
