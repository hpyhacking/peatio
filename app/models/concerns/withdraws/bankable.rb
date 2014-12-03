module Withdraws
  module Bankable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :fund_extra

      delegate :name, to: :member, prefix: true

      alias_attribute :remark, :id
    end

    def audit!
      with_lock do
        if account.examine
          accept!
          process! if quick?
        else
          mark_suspect!
        end
      end
    end

  end
end
