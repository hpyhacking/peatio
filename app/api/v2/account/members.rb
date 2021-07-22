# frozen_string_literal: true

module API
  module V2
    module Account
      class Members < Grape::API
        desc 'Returns current member',
             success: API::V2::Entities::Member
        get '/members/me' do
          present current_user, with: API::V2::Entities::Member
        end

        desc 'Enable/Disable beneficiaries whitelisting for the specific user',
             success: API::V2::Entities::Member
        params do
          requires :otp,
                   type: { value: Integer, message: 'account.beneficiaries_whitelisting.non_integer_otp' },
                   allow_blank: false,
                   desc: 'OTP to perform action'
          requires :state, type: Boolean, desc: 'The state of user beneficiaries whitelisting.'
        end
        post '/members/beneficiaries_whitelisting' do
          unless Vault::TOTP.validate?(current_user.uid, params[:otp])
            error!({ errors: ['account.beneficiaries_whitelisting.invalid_otp'] }, 422)
          end

          if !Peatio::App.config.force_beneficiaries_whitelisting
            if current_user.beneficiaries_whitelisting == params[:state]
              error!({ errors: ['account.beneficiaries_whitelisting.same_state'] }, 422)
            else
              Beneficiary.transaction do
                current_user.update!(beneficiaries_whitelisting: params[:state])
                if params[:state] == false
                  current_user.beneficiaries.active.each { |b| b.disable! }
                end
              end

              present current_user, with: API::V2::Entities::Member
            end
          else
            error!({ errors: 'member.force_beneficiaries_whitelisting.enabled' }, 422)
          end
        end
      end
    end
  end
end
