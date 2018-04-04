module ManagementAPIv1
  class Withdraws < Grape::API

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
      if params[:currency].present?
        currency = Currency.find_by!(code: params[:currency])
      end

      if params[:uid].present?
        member = Authentication.find_by!(provider: :barong, uid: params[:uid]).member
      end

      Withdraw
        .order(id: :desc)
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
      detail 'You can pass «state» set to «submitted» if you want to start processing withdraw.'
      success ManagementAPIv1::Entities::Withdraw
    end
    params do
      requires :uid,      type: String, desc: 'The shared user ID.'
      optional :tid,      type: String, desc: 'The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied.'
      requires :rid,      type: String, desc: 'The beneficiary ID or wallet address on the Blockchain.'
      requires :currency, type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'The currency code.'
      requires :amount,   type: BigDecimal, desc: 'The amount to withdraw.'
      optional :state,    type: String, values: %w[prepared submitted], desc: 'The withdraw state to apply.'
    end
    post '/withdraws/new' do
      currency = Currency.find_by!(code: params[:currency])
      member   = Authentication.find_by(provider: :barong, uid: params[:uid])&.member
      withdraw = "withdraws/#{currency.type}".camelize.constantize.new \
        destination_id: params[:destination_id],
        sum:            params[:amount],
        member:         member,
        currency:       currency,
        tid:            params[:tid],
        rid:            params[:rid]

      if withdraw.coin? && member
        member.coin_withdraw_destinations
              .build(currency: currency, address: params[:rid], label: params[:rid])
      else
        member.fiat_withdraw_destinations
              .build(currency: currency)
              .dummy
      end
        .tap(&:save)
        .tap { |record| withdraw.destination = record }

      if withdraw.save
        withdraw.submit! if params[:state] == 'submitted'
        present withdraw, with: ManagementAPIv1::Entities::Withdraw
      else
        body errors: withdraw.errors.full_messages
        status 422
      end
    end

    desc 'Updates withdraw state.' do
      @settings[:scope] = :write_withdraws
      detail '«submitted» – system will check for suspected activity, lock the money, and process the withdraw. ' \
             '«canceled» – system will mark withdraw as «canceled», and unlock the money.'
      success ManagementAPIv1::Entities::Withdraw
    end
    params do
      requires :tid,   type: String, desc: 'The shared transaction ID.'
      requires :state, type: String, values: %w[submitted canceled]
    end
    put '/withdraws/state' do
      record = Withdraw.find_by!(params.slice(:tid))
      record.with_lock do
        { submitted: :submit,
          cancelled: :cancel
        }.each do |state, event|
          next unless params[:state] == state.to_s
          if record.aasm.may_fire_event?(event)
            record.aasm.fire!(event)
            present record, with: ManagementAPIv1::Entities::Withdraw
            break status 200
          else
            break status 422
          end
        end
      end
    end
  end
end
