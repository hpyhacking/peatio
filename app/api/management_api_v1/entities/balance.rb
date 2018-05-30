# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  module Entities
    class Balance < Base
      expose(:uid, documentation: { type: String, desc: 'The shared user ID.' }) { |w| w.member.uid }
      expose(:balance, documentation: { type: String, desc: 'The account balance.' }, format_with: :decimal)
      expose(:locked, documentation: { type: String, desc: 'The locked account balance.' }, format_with: :decimal)
    end
  end
end
