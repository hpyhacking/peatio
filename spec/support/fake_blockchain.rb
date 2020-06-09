# frozen_string_literal: true

class FakeBlockchain < Peatio::Blockchain::Abstract
  def initialize
    @features = { cash_addr_format: false, case_sensitive: true }
  end

  def configure(settings = {}); end
end

class FakeWallet < Peatio::Wallet::Abstract
  def initialize(features = {})
    @features = features
  end

  def configure(settings = {}); end
end

Peatio::Blockchain.registry[:fake] = FakeBlockchain
Peatio::Wallet.registry[:fake] = FakeWallet
