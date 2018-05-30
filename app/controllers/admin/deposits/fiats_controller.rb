# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/deposits/base_controller'

module Admin
  module Deposits
    class FiatsController < BaseController
      def index
        q = ::Deposits::Fiat.where(currency: currency).includes(:member).includes(:currency)
        @latest_deposits = q.where('created_at <= ?', 1.day.ago).order('id DESC')
        @all_deposits    = q.where('created_at > ?', 1.day.ago).order('id DESC')
      end

      def new
        @deposit = ::Deposits::Fiat.new
      end

      def show
        @deposit = ::Deposits::Fiat.where(currency: currency).find(params[:id])
        flash.now[:notice] = t('.notice') if @deposit.accepted?
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
        ::Deposits::Fiat.where(currency: currency).find(params[:id]).charge!
        redirect_to :back
      end

    private

      def deposit_params
        params.require(:deposits_fiat).slice(:sn, :amount)
              .merge(currency: currency)
              .permit!
      end
    end
  end
end

