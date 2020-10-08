# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Beneficiaries < Grape::API
        namespace :beneficiaries do

          desc 'Get list of user beneficiaries' do
            @settings[:scope] = :read_beneficiaries
            success API::V2::Management::Entities::Beneficiary
          end
          params do
            requires :uid,
                      type: String,
                      desc: 'The shared user ID.'
            optional :currency,
                      type: String,
                      values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'management.currency.doesnt_exist' },
                      as: :currency_id,
                      desc: 'Beneficiary currency code.'
            optional :state,
                      type: String,
                      values: { value: -> { ::Beneficiary::STATES_AVAILABLE_FOR_MEMBER.map(&:to_s) }, message: 'management.beneficiary.invalid_state'},
                      desc: 'Defines either beneficiary active - user can use it to withdraw money'\
                            'or pending - requires beneficiary activation with pin.'

          end
          post '/list' do
            member  = Member.find_by!(uid: params[:uid])

            member
              .beneficiaries
              .available_to_member
              .tap { |q| q.where!(currency_id: params[:currency_id]) if params[:currency_id].present? }
              .tap {|q| q.where!(state: params[:state]) if params[:state].present? }
              .yield_self { |b| present paginate(b), with: API::V2::Management::Entities::Beneficiary }

            status 200
          end

          desc 'Create new beneficiary' do
            @settings[:scope] = :write_beneficiaries
            success API::V2::Management::Entities::Beneficiary
          end
          params do
            requires :currency,
                    type: String,
                    values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'management.currency.doesnt_exist' },
                    as: :currency_id,
                    desc: 'Beneficiary currency code.'
            requires :name,
                    type: String,
                    allow_blank: false,
                    values: { value: ->(v) { v.present? && v.size <= 64 }, message: 'management.beneficiary.too_long_name' },
                    desc: 'Human rememberable name which refer beneficiary.'
            optional :description,
                    type: String,
                    values: { value: ->(v) { v.size <= 255 }, message: 'management.beneficiary.too_long_description' },
                    desc: 'Human rememberable description which refer beneficiary.'
            requires :data,
                    type: { value: JSON, message: 'management.beneficiary.non_json_data' },
                    allow_blank: false,
                    desc: 'Beneficiary data in JSON format'
            requires :uid,
                    type: String,
                    desc: 'The shared user ID.'
            optional :state,
                    type: String,
                    values: { value: -> { ::Beneficiary::STATES_AVAILABLE_FOR_MEMBER.map(&:to_s) }, message: 'management.beneficiary.invalid_state'},
                    desc: 'Defines either beneficiary active - user can use it to withdraw money'\
                          'or pending - requires beneficiary activation with pin.'
          end
          post do
            declared_params = declared(params)
            member   = Member.find_by!(uid: params[:uid])
            currency = Currency.find_by!(id: params[:currency_id])

            if !currency.withdrawal_enabled?
              error!({ errors: ['management.currency.withdrawal_disabled'] }, 422)
            elsif currency.coin? && declared_params.dig(:data, :address).blank?
              error!({ errors: ['management.beneficiary.missing_address_in_data'] }, 422)
            elsif currency.fiat? && declared_params.dig(:data, :full_name).blank?
              error!({ errors: ['management.beneficiary.missing_full_name_in_data'] }, 422)
            end

            # Since data is stored in MySQL JSON format we iterate through all
            # beneficiaries one by one to detect duplicated address.
            if currency.coin? &&
                member
                  .beneficiaries
                  .available_to_member
                  .where(currency: currency)
                  .any? { |b| b.data['address'] == declared_params.dig(:data, :address) }
              error!({ errors: ['management.beneficiary.duplicate_address'] }, 422)
            end

            present member
                      .beneficiaries
                      .create!(declared_params.except(:uid)),
                    with: API::V2::Management::Entities::Beneficiary
          rescue ActiveRecord::RecordInvalid => e
            report_exception(e)
            error!({ errors: ['management.beneficiary.failed_to_create'] }, 422)
          end
        end
      end
    end
  end
end