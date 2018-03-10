module Private
  class WithdrawDestinationsController < BaseController

    def create
      ccy = Currency.find_by_code(params[:currency])
      return head :unprocessable_entity unless ccy

      klass = "withdraw_destination/#{ccy.type}".camelize.constantize
      data  = params.slice(:label, *klass.fields.keys)
                    .merge!(currency: ccy)
                    .merge!(member: current_user)
                    .permit!

      if (record = klass.new(data)).save
        render json: record
      else
        render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      dest    = current_user.withdraw_destinations.find(params[:id])
      account = current_user.ac(dest.currency)
      account.update!(default_withdraw_destination_id: params[:id])
      head :ok
    end
  end
end
