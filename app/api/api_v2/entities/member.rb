module APIv2
  module Entities
    class Member < Base
      expose :sn
      expose :name
      expose :email
      expose :activated
      expose :accounts, using: ::APIv2::Entities::Account
    end
  end
end
