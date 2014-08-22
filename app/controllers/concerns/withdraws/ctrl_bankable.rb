module Withdraws
  module CtrlBankable
    extend ActiveSupport::Concern
    include Withdrawable
  end
end