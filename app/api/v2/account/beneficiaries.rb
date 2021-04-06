# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Account
      class Beneficiaries < Grape::API
        helpers ::API::V2::ParamHelpers

        before { withdraws_must_be_permitted! }

        namespace :beneficiaries do
          desc 'Get list of user beneficiaries',
               is_array: true,
               success: API::V2::Entities::Beneficiary

          params do
            use :pagination
            optional :currency,
                     type: String,
                     values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist' },
                     as: :currency_id,
                     desc: 'Beneficiary currency code.'
            optional :state,
                     type: String,
                     values: { value: -> { ::Beneficiary::STATES_AVAILABLE_FOR_MEMBER.map(&:to_s) }, message: 'account.beneficiary.invalid_state'},
                     desc: 'Defines either beneficiary active - user can use it to withdraw money'\
                           'or pending - requires beneficiary activation with pin.'

          end
          get do
            user_authorize! :read, ::Beneficiary

            current_user
              .beneficiaries
              .available_to_member
              .tap do |q|
                q.where!(currency_id: params[:currency_id]) if params[:currency_id].present?
              end
              .tap do |q|
                q.where!(state: params[:state]) if params[:state].present?
              end
              .yield_self do |b|
                present paginate(b), with: API::V2::Entities::Beneficiary
              end
          end

          desc 'Get beneficiary by ID',
               success: API::V2::Entities::Beneficiary

          params do
            requires :id,
                     type: { value: Integer, message: 'account.beneficiary.non_integer_id' },
                     desc: 'Beneficiary Identifier in Database'
          end
          get ':id' do
            user_authorize! :read, ::Beneficiary

            current_user
              .beneficiaries
              .available_to_member
              .find_by!(id: params[:id])
              .yield_self { |b| present b, with: API::V2::Entities::Beneficiary }
          end

          desc 'Create new beneficiary',
               success: API::V2::Entities::Beneficiary

          params do
            requires :currency,
                     type: String,
                     values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist' },
                     as: :currency_id,
                     desc: 'Beneficiary currency code.'
            requires :name,
                     type: String,
                     allow_blank: false,
                     values: { value: ->(v) { v.present? && v.size <= 64 }, message: 'account.beneficiary.too_long_name' },
                     desc: 'Human rememberable name which refer beneficiary.'
            optional :description,
                     type: String,
                     values: { value: ->(v) { v.size <= 255 }, message: 'account.beneficiary.too_long_description' },
                     desc: 'Human rememberable name which refer beneficiary.'
            requires :data,
                     type: { value: JSON, message: 'account.beneficiary.non_json_data' },
                     allow_blank: false,
                     desc: 'Beneficiary data in JSON format'
          end
          post do
            user_authorize! :create, ::Beneficiary

            declared_params = declared(params)

            currency = Currency.find_by!(id: params[:currency_id])

            if !currency.withdrawal_enabled?
              error!({ errors: ['account.currency.withdrawal_disabled'] }, 422)
            elsif currency.coin? && declared_params.dig(:data, :address).blank?
              error!({ errors: ['account.beneficiary.missing_address_in_data'] }, 422)
            elsif currency.fiat? && declared_params.dig(:data, :full_name).blank?
              error!({ errors: ['account.beneficiary.missing_full_name_in_data'] }, 422)
            end

            # Since data is stored in MySQL JSON format we iterate through all
            # beneficiaries one by one to detect duplicated address.
            if currency.coin? &&
                current_user
                  .beneficiaries
                  .available_to_member
                  .where(currency: currency)
                  .any? { |b| b.data['address'] == declared_params.dig(:data, :address) }
              error!({ errors: ['account.beneficiary.duplicate_address'] }, 422)
            end

            present current_user
                      .beneficiaries
                      .create!(declared_params),
                    with: API::V2::Entities::Beneficiary
          rescue ActiveRecord::RecordInvalid => e
            report_exception(e)
            error!({ errors: ['account.beneficiary.failed_to_create'] }, 422)
          end

          desc 'Resend beneficiary pin'
          params do
            requires :id,
                     type: { value: Integer, message: 'account.beneficiary.non_integer_id' },
                     desc: 'Beneficiary Identifier in Database'
          end
          patch ':id/resend_pin' do
            user_authorize! :update, ::Beneficiary

            beneficiary = current_user
                              .beneficiaries
                              .available_to_member
                              .find_by!(id: params[:id])

            unless beneficiary.pending?
              error!({ errors: ['account.beneficiary.cant_resend'] }, 422)
            end

            if Time.now - beneficiary.sent_at < 60
              error!({ errors: ['account.beneficiary.cant_resend_within_1_minute'], sent_at: beneficiary.sent_at.iso8601 }, 422)
            end

            beneficiary.regenerate_pin!
            status 204
          end


          desc 'Activates beneficiary with pin',
               success: API::V2::Entities::Beneficiary

          params do
            requires :id,
                     type: { value: Integer, message: 'account.beneficiary.non_integer_id' },
                     desc: 'Beneficiary Identifier in Database'

            requires :pin,
                     type: { value: Integer, message: 'account.beneficiary.non_integer_pin' },
                     desc: 'Pin code for beneficiary activation'
          end
          patch ':id/activate' do
            user_authorize! :update, ::Beneficiary

            beneficiary = current_user
                            .beneficiaries
                            .available_to_member
                            .find_by!(id: params[:id])

            unless beneficiary.pending?
              error!({ errors: ['account.beneficiary.cant_activate'] }, 422)
            end

            if beneficiary.activate!(params[:pin])
              present beneficiary, with: API::V2::Entities::Beneficiary
            else
              error!({ errors: ['account.beneficiary.invalid_pin'] }, 422)
            end
          end

          desc 'Delete beneficiary'

          params do
            requires :id,
                     type: { value: Integer, message: 'account.beneficiary.non_integer_id' },
                     desc: 'Beneficiary Identifier in Database'
          end
          delete ':id' do
            user_authorize! :destroy, ::Beneficiary

            beneficiary = current_user
                            .beneficiaries
                            .available_to_member
                            .find_by!(id: params[:id])

            if beneficiary.archive!
              body false
            else
              error!({ errors: ['account.beneficiary.cant_delete'] }, 422)
            end
          end
        end
      end
    end
  end
end
