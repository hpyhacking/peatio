module Withdraws
  module Coinable
    extend ActiveSupport::Concern

    def set_fee
      self.fee = "0.0001".to_d
    end

    def blockchain_url
      currency_obj.blockchain_url(txid)
    end

    def audit!
      inspection = CoinAPI[currency].inspect_address!(fund_uid)

      if inspection[:is_valid] == false
        Rails.logger.info "#{self.class.name}##{id} uses invalid address: #{fund_uid.inspect}"
        reject
        save!
      elsif inspection[:is_mine] == true
        Rails.logger.info "#{self.class.name}##{id} uses hot wallet address: #{fund_uid.inspect}"
        reject
        save!
      else
        super
      end
    end

    def as_json(options={})
      super(options).merge({
        blockchain_url: blockchain_url
      })
    end

  end
end

