# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Member < Base
      expose :sn
      expose :email
      expose(:accounts, using: ::APIv2::Entities::Account) do |m|
        m.accounts.enabled.includes(:currency)
      end
    end
  end
end
