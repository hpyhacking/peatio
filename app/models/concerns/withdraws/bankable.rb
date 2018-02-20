module Withdraws
  module Bankable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :fund_extra

      alias_attribute :remark, :id
    end

  end
end
