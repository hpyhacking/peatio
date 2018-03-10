module Withdraws
  module Coinable
    extend ActiveSupport::Concern

    def wallet_url
      if destination.address? && currency.wallet_url_template?
        currency.wallet_url_template.gsub('#{address}', destination.address)
      end
    end

    def transaction_url
      if txid? && currency.transaction_url_template?
        currency.transaction_url_template.gsub('#{txid}', txid)
      end
    end

    def audit!
      inspection = currency.api.inspect_address!(destination.address)

      if inspection[:is_valid] == false
        Rails.logger.info "#{self.class.name}##{id} uses invalid address: #{destination.address.inspect}"
        reject
        save!
      elsif inspection[:is_mine] == true
        Rails.logger.info "#{self.class.name}##{id} uses hot wallet address: #{destination.address.inspect}"
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

