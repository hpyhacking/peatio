# encoding: UTF-8
# frozen_string_literal: true

module API::V2
  module ExceptionHandlers
    def self.included(base)
      base.instance_eval do
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          errors_array = e.full_messages.map do |err|
            err.split.last
          end
          error!({ errors: errors_array }, 422)
        end

        rescue_from Grape::Exceptions::MethodNotAllowed do |_e|
          error!({ errors: 'server.method_not_allowed' }, 405)
        end

        rescue_from Grape::Exceptions::InvalidMessageBody do |_e|
          error!({ errors: 'server.method.invalid_message_body' }, 400)
        end

        rescue_from Peatio::Auth::Error do |e|
          report_exception(e)
          error!({ errors: ['jwt.decode_and_verify'] }, 401)
        end

        rescue_from ActiveRecord::RecordNotFound do |_e|
          error!({ errors: ['record.not_found'] }, 404)
        end

        # Known Vault Error from Vault::TOTP.with_human_error
        rescue_from(Vault::TOTP::Error) do |_|
          error!({ errors: ['invalid_otp'] }, 422)
        end

        rescue_from :all do |e|
          report_exception(e)
          error!({ errors: ['server.internal_error'] }, 500)
        end
      end
    end
  end
end
