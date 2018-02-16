module Concerns
  module DisableMarketsUI
    extend ActiveSupport::Concern

    included do
      before_action do
        head 204 if ENV['DISABLE_MARKETS_UI'] && !try(:current_user)&.admin?
      end
    end
  end
end
