# encoding: UTF-8
# frozen_string_literal: true

module Concerns
  module DisableCabinetUI
    extend ActiveSupport::Concern

    included do
      before_action do
        head 204 if ENV['DISABLE_CABINET_UI'] && !try(:current_user)&.admin?
      end
    end
  end
end
