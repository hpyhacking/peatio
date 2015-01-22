module Withdraws
  module CtrlCoinable
    extend ActiveSupport::Concern
    include Withdrawable
  end
end