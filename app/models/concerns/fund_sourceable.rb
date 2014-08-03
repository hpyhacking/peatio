module FundSourceable
  extend ActiveSupport::Concern

  included do
    attr_accessor :fund_source
    before_validation :set_fund_extra_and_fund_uid, on: :create
    validates :fund_source, presence: true, on: :create
  end

  def set_fund_extra_and_fund_uid
    if fs = FundSource.find_by_id(fund_source)
      self.fund_extra = fs.extra
      self.fund_uid = fs.uid
    end
  end

  def fund_extra
    if self.currency_obj.coin?
      self['fund_extra']
    else
      I18n.t("banks.#{self['fund_extra']}")
    end
  end
end
