# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class AccountingsController < BaseController

    before_action :init_date_range, only: [:income_statement]

    def balance_sheet
      @assets = ::Operations::Asset.balance
      @liabilities = ::Operations::Liability.balance
      @balances = @assets.merge(@liabilities){ |k, a, b| a - b}
    end

    def income_statement
      created_at_from = Date.parse(@date_range.split('-')[0].strip).beginning_of_day
      created_at_to = Date.parse(@date_range.split('-')[1].strip).end_of_day
      @revenues = ::Operations::Revenue.balance(created_at_from: created_at_from, created_at_to: created_at_to)
      @expenses = ::Operations::Expense.balance(created_at_from: created_at_from, created_at_to: created_at_to)
      @profits = @revenues.merge(@expenses){ |k, a, b| a - b}
    end

    private

    def init_date_range
      if params[:date_range]
        @date_range = params[:date_range]
      else
        @date_range = Date.today.beginning_of_month.strftime("%Y/%m/%d") \
                      + "-" \
                      + Date.today.strftime("%Y/%m/%d")
      end
    end
  end
end
