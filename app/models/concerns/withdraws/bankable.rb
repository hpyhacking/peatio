module Withdraws
  module Bankable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :fund_extra

      delegate :name, to: :member, prefix: true

      alias_attribute :remark, :id
    end

  end
end
