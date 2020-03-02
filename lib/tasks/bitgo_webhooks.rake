# encoding: UTF-8
# frozen_string_literal: true

namespace :bitgo do
  desc 'Add a webhook that will result in an HTTP callback at the specified URL from BitGo when events are triggered.'
  task :webhooks, [:url] => [:environment] do
    Wallet.deposit.active.where(gateway: :bitgo).each do |w|
      w.service.register_webhooks!(args[:url])
    end
  end
end
