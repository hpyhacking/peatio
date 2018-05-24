# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Member < Base
      expose :sn
      expose :email
      expose(:accounts, using: ::APIv2::Entities::Account) { |m| m.accounts.enabled }
    end
  end
end
