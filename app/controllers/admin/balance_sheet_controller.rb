# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class BalanceSheetController < BaseController
    def index
      @assets = ::Operations::Asset.balance
      @liabilities = ::Operations::Liability.balance
      @balances = @assets.merge(@liabilities){ |k, a, b| a - b}
    end
  end
end
