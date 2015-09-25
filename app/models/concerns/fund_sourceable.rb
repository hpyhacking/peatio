module FundSourceable
  extend ActiveSupport::Concern

  included do
    attr_accessor :fund_source
    before_validation :set_fund_source_attributes, on: :create
    validates :fund_source, presence: true, on: :create
  end

  def set_fund_source_attributes
    if fs = FundSource.find_by(id: fund_source)
      self.fund_extra = fs.extra
      self.fund_uid = fs.uid.strip
    end
  end
end
