module APIv2
  module Entities
    class Member < Base
      expose :sn
      expose :name
      expose :email
      expose :activated
    end
  end
end
