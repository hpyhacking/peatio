# encoding: UTF-8
# frozen_string_literal: true

namespace :accounts do
  desc 'Create missing accounts for existing members.'
  task touch: :environment do
    Member.find_each(&:touch_accounts)
  end
end
