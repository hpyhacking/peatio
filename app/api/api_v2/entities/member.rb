module APIv2
  module Entities
    class Member < Base
      expose :sn
      expose :email
      expose :accounts, using: ::APIv2::Entities::Account
    end
  end
end
