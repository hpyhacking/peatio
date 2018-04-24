require_dependency 'member'

class Member
  module Levels
    class << self
      def get(data)
        if Numeric === data
          from_numerical_barong_level(data)
        else
          data.presence
        end
      end

      def from_numerical_barong_level(num)
        case num
          when 1 then :email_verified
          when 2 then :phone_verified
          else num >= 3 ? :identity_verified : :unverified
        end
      end
    end
  end
end
