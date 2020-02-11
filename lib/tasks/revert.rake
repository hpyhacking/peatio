# encoding: UTF-8
# frozen_string_literal: true

# Usage
# for revert all trading activity for particular user:
# $> bundle exec rake revert:trading_activity["admin@barong.io"]
namespace :revert do
  desc 'Revert user trade activity.'
  task :trading_activity, [:member_email] => [:environment] do |_, args|

    member = Member.find_by(email: args[:member_email])

    # For each trade create revert Liabilities, Revenues and update User balances
    # TODO: Add ability to revert particular trades.
    member.revert_trading_activity!(member.trades.order(id: :desc))
  end
end
