module Withdraws
  module Coinable
    extend ActiveSupport::Concern

    def wallet_url
      if fund_uid? && currency.wallet_url_template?
        currency.wallet_url_template.gsub('#{address}', fund_uid)
      end
    end

    def transaction_url
      if txid? && currency.transaction_url_template?
        currency.transaction_url_template.gsub('#{txid}', txid)
      end
    end

    def audit!
      inspection = currency.api.inspect_address!(fund_uid)

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

    def as_json(*)
      super.merge \
        wallet_url:      wallet_url,
        transaction_url: transaction_url
    end
  end
end

