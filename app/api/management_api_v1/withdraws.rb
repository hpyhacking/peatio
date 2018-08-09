# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Withdraws < Grape::API

    helpers do
      def perform_action(withdraw, action)
        withdraw.with_lock do
          case action
            when 'process'
              withdraw.submit!
              # Process fiat withdraw immediately. Crypto withdraws will be processed by workers.
              if withdraw.fiat?
                withdraw.accept!
                if withdraw.quick?
                  withdraw.process!
                  withdraw.dispatch!
                  withdraw.success!
                end
              end
            when 'cancel'
              withdraw.cancel!
          end
        end
      end
    end

    desc 'Returns withdraws as paginated collection.' do
      @settings[:scope] = :read_withdraws
      success ManagementAPIv1::Entities::Withdraw
    end
    params do
      optional :uid,      type: String,  desc: 'The shared user ID.'
      optional :currency, type: String,  values: -> { Currency.codes(bothcase: true) }, desc: 'The currency code.'
      optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'The page number (defaults to 1).'
      optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'The number of objects per page (defaults to 100, maximum is 1000).'
      optional :state,    type: String,  values: -> { Withdraw::STATES.map(&:to_s) }, desc: 'The state to filter by.'
    end
    post '/withdraws' do
      currency = Currency.find(params[:currency]) if params[:currency].present?
      member   = Authentication.find_by!(provider: :barong, uid: params[:uid]).member if params[:uid].present?

      Withdraw
        .order(id: :desc)
        .includes(:currency)
        .tap { |q| q.where!(currency: currency) if currency }
        .tap { |q| q.where!(member: member) if member }
        .tap { |q| q.where!(aasm_state: params[:state]) if params[:state] }
        .page(params[:page])
        .per(params[:limit])
        .tap { |q| present q, with: ManagementAPIv1::Entities::Withdraw }
      status 200
    end

    desc 'Returns withdraw by ID.' do
      @settings[:scope] = :read_withdraws
      success ManagementAPIv1::Entities::Withdraw
    end
    params do
      requires :tid, type: String, desc: 'The shared transaction ID.'
    end
    post '/withdraws/get' do
      present Withdraw.find_by!(params.slice(:tid)), with: ManagementAPIv1::Entities::Withdraw
    end

    desc 'Creates new withdraw.' do
      @settings[:scope] = :write_withdraws
      detail 'Creates new withdraw. The behaviours for fiat and crypto withdraws are different. ' \
             'Fiat: money are immediately locked, withdraw state is set to «submitted», system workers ' \
                   'will validate withdraw later against suspected activity, and assign state to «rejected» or «accepted». ' \
                   'The processing will not begin automatically. The processing may be initiated manually from admin panel or by PUT /management_api/v1/withdraws/action. ' \
             'Coin: money are immediately locked, withdraw state is set to «submitted», system workers ' \
                   'will validate withdraw later against suspected activity, validate withdraw address and '
                   'set state to «rejected» or «accepted». ' \
                   'Then in case state is «accepted» withdraw workers will perform interactions with blockchain. ' \
                   'The withdraw receives new state «processing». Then withdraw receives state either «confirming» or «failed».' \
                   'Then in case state is «confirming» withdraw confirmations workers will perform interactions with blockchain.' \
                   'Withdraw receives state «succeed» when it receives minimum necessary amount of confirmations.'
      success ManagementAPIv1::Entities::Withdraw
    end
    params do
      requires :uid,      type: String, desc: 'The shared user ID.'
      optional :tid,      type: String, desc: 'The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied.'
      requires :rid,      type: String, desc: 'The beneficiary ID or wallet address on the Blockchain.'
      requires :currency, type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'The currency code.'
      requires :amount,   type: BigDecimal, desc: 'The amount to withdraw.'
      optional :action,   type: String, values: %w[process], desc: 'The action to perform.'
    end
    post '/withdraws/new' do
      currency = Currency.find(params[:currency])
      member   = Authentication.find_by(provider: :barong, uid: params[:uid])&.member
      withdraw = "withdraws/#{currency.type}".camelize.constantize.new \
        sum:            params[:amount],
        member:         member,
        currency:       currency,
        tid:            params[:tid],
        rid:            params[:rid]

      if withdraw.save
        withdraw.with_lock { withdraw.submit! }
        perform_action(withdraw, params[:action]) if params[:action]
        present withdraw, with: ManagementAPIv1::Entities::Withdraw
      else
        body errors: withdraw.errors.full_messages
        status 422
      end
    end

    desc 'Performs action on withdraw.' do
      @settings[:scope] = :write_withdraws
      detail '«process» – system will lock the money, check for suspected activity, validate recipient address, and initiate the processing of the withdraw. ' \
             '«cancel»  – system will mark withdraw as «canceled», and unlock the money.'
      success ManagementAPIv1::Entities::Withdraw
    end
    params do
      requires :tid,    type: String, desc: 'The shared transaction ID.'
      requires :action, type: String, values: %w[process cancel], desc: 'The action to perform.'
    end
    put '/withdraws/action' do
      record = Withdraw.find_by!(params.slice(:tid))
      perform_action(record, params[:action])
      present record, with: ManagementAPIv1::Entities::Withdraw
    end
  end
end
