module FundSourceable
  extend ActiveSupport::Concern

  included do
    attr_accessor :fund_source_id
    before_validation :set_fund_source_attributes, on: :create
    validates :fund_extra, :fund_uid, presence: true, on: :create
  end

  def set_fund_source_attributes
    if fund_extra.nil? && fund_uid.nil? && fund_source = FundSource.find_by(id: fund_source_id)
      self.fund_extra = fund_source.extra
      self.fund_uid = fund_source.uid.strip
    end
  end
end
