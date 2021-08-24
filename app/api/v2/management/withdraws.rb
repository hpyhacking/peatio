# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Withdraws < Grape::API

        helpers do
          def perform_action(withdraw, action)
            withdraw.with_lock do
              case action
                when 'review'
                  withdraw.accept!
                  withdraw.process!
                  withdraw.review!
                when 'process'
                  withdraw.accept!
                  # Process fiat withdraw immediately. Crypto withdraws will be processed by workers.
                  if withdraw.currency.fiat?
                    withdraw.process!
                    withdraw.dispatch!
                    withdraw.success!
                  end
                when 'cancel'
                  withdraw.cancel!
                when 'reject'
                  withdraw.reject!
                when 'success'
                  withdraw.success!
              end
            end
          end
        end

        desc 'Returns withdraws as paginated collection.' do
          @settings[:scope] = :read_withdraws
          success API::V2::Management::Entities::Withdraw
        end
        params do
          optional :uid, type: String,  desc: 'The shared user ID.'
          optional :currency, type: String,  values: -> { Currency.codes(bothcase: true) }, desc: 'The currency code.'
          optional :page, type: Integer, default: 1, integer_gt_zero: true, desc: 'The page number (defaults to 1).'
          optional :blockchain_key, type: String, values: -> { ::Blockchain.pluck(:key) }, desc: 'Blockchain key of the requested withdrawal'
          optional :limit, type: Integer, default: 100, range: 1..1000, desc: 'The number of objects per page (defaults to 100, maximum is 1000).'
          optional :state, type: String,  values: -> { Withdraw::STATES.map(&:to_s) }, desc: 'The state to filter by.'
        end
        post '/withdraws' do
          currency = Currency.find(params[:currency]) if params[:currency].present?
          member   = Member.find_by!(uid: params[:uid]) if params[:uid].present?

          Withdraw
            .order(id: :desc)
            .includes(:member, :currency)
            .tap { |q| q.where!(currency: currency) if currency }
            .tap { |q| q.where!(member: member) if member }
            .tap { |q| q.where!(aasm_state: params[:state]) if params[:state] }
            .tap { |q| q.where!(blockchain_key: params[:blockchain_key]) if params[:blockchain_key] }
            .page(params[:page])
            .per(params[:limit])
            .tap { |q| present q, with: API::V2::Management::Entities::Withdraw }
          status 200
        end

        desc 'Returns withdraw by ID.' do
          @settings[:scope] = :read_withdraws
          success API::V2::Management::Entities::Withdraw
        end
        params do
          requires :tid, type: String, desc: 'The shared transaction ID.'
        end
        post '/withdraws/get' do
          present Withdraw.find_by!(params.slice(:tid)), with: API::V2::Management::Entities::Withdraw
        end

        desc 'Creates new withdraw.' do
          @settings[:scope] = :write_withdraws
          detail 'Creates new withdraw. The behaviours for fiat and crypto withdraws are different. ' \
                'Fiat: money are immediately locked, withdraw state is set to «submitted», system workers ' \
                      'will validate withdraw later against suspected activity, and assign state to «rejected» or «accepted». ' \
                      'The processing will not begin automatically. The processing may be initiated manually from admin panel or by PUT /management_api/v1/withdraws/action. ' \
                'Coin: money are immediately locked, withdraw state is set to «submitted», system workers ' \
                      'will validate withdraw later against suspected activity, validate withdraw address and ' \
                      'set state to «rejected» or «accepted». ' \
                      'Then in case state is «accepted» withdraw workers will perform interactions with blockchain. ' \
                      'The withdraw receives new state «processing». Then withdraw receives state either «confirming» or «failed».' \
                      'Then in case state is «confirming» withdraw confirmations workers will perform interactions with blockchain.' \
                      'Withdraw receives state «succeed» when it receives minimum necessary amount of confirmations.'
          success API::V2::Management::Entities::Withdraw
        end
        params do
          requires :uid,            type: String, desc: 'The shared user ID.'
          optional :tid,            type: String, desc: 'The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied.'
          optional :rid,            type: String, desc: 'The beneficiary ID or wallet address on the Blockchain.'
          optional :beneficiary_id, type: String, desc: 'ID of Active Beneficiary belonging to user.'
          optional :blockchain_key, type: String, values: -> { ::Blockchain.pluck(:key) }, desc: 'Blockchain key of the requested withdrawal'
          requires :currency,       type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'The currency code.'
          requires :amount,         type: BigDecimal, desc: 'The amount to withdraw.'
          optional :note,           type: String, desc: 'The note for withdraw.'
          optional :action,         type: String, values: %w[process review], desc: 'The action to perform.'
          optional :transfer_type,  type: String,
                                    values: { value: -> { Withdraw::TRANSFER_TYPES.keys }, message: 'account.withdraw.transfer_type_not_in_list' },
                                    desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:transfer_type][:desc] }

          exactly_one_of :rid, :beneficiary_id
          exactly_one_of :beneficiary_id, :blockchain_key
        end
        post '/withdraws/new' do
          member = Member.find_by(uid: params[:uid])

          beneficiary = Beneficiary.find_by(id: params[:beneficiary_id]) if params[:beneficiary_id].present?
          if params[:rid].blank? && beneficiary.blank?
            error!({ errors: ['management.beneficiary.doesnt_exist'] }, 422)
          elsif params[:rid].blank? && !beneficiary&.active?
            error!({ errors: ['management.beneficiary.invalid_state_for_withdrawal'] }, 422)
          end

          currency = Currency.find(params[:currency])
          blockchain_key = beneficiary.present? ? beneficiary.blockchain_key : params[:blockchain_key]

          blockchain_currency = BlockchainCurrency.find_network(blockchain_key, params[:currency])
          error!({ errors: ['management.withdraws.network_not_found'] }, 422) unless blockchain_currency.present?

          unless blockchain_currency.withdrawal_enabled?
            error!({ errors: ['management.currency.withdrawal_disabled'] }, 422)
          end

          if params[:tid].present?
            error!({ errors: ['TID already exist'] }, 422) if Withdraw.where(tid: params[:tid]).present?
          end

          declared_params = declared(params, include_missing: false).slice(:tid, :rid, :note, :transfer_type).merge(
            sum: params[:amount],
            member: member,
            currency: currency,
            tid: params[:tid],
            blockchain_key: blockchain_key
          )

          declared_params.merge!(beneficiary: beneficiary) if params[:beneficiary_id].present?
          withdraw = "withdraws/#{currency.type}".camelize.constantize.new(declared_params)

          withdraw.save!
          withdraw.with_lock { withdraw.accept! }
          perform_action(withdraw, params[:action]) if params[:action]
          present withdraw, with: API::V2::Management::Entities::Withdraw
        rescue ::Account::AccountError => e
          report_api_error(e, request)
          error!({ errors: [e.to_s] }, 422)
        rescue => e
          report_exception(e)
          error!({ errors: ['Failed to create withdraw!'] }, 422)
        end

        desc 'Performs action on withdraw.' do
          @settings[:scope] = :write_withdraws
          detail '«process» – system will lock the money, check for suspected activity, validate recipient address, and initiate the processing of the withdraw. ' \
                '«cancel»  – system will mark withdraw as «canceled», and unlock the money.' \
                '«reject»  – system will mark withdraw as «rejected», and unlock the money.' \
                '«review»  – system will mark withdraw as «under_review», and lock the money.' \
                '«success»  – system will mark withdraw as «succeed», and subtract the money from the account. (works only with fiat)'
          success API::V2::Management::Entities::Withdraw
        end
        params do
          requires :tid,    type: String, desc: 'The shared transaction ID.'
          requires :action, type: String, values: %w[process cancel reject review success], desc: 'The action to perform.'
        end
        put '/withdraws/action' do
          record = Withdraw.find_by!(params.slice(:tid))
          perform_action(record, params[:action])
          present record, with: API::V2::Management::Entities::Withdraw
        end
      end
    end
  end
end
