module Admin
  class MembersController < BaseController
    load_and_authorize_resource

    def index
      @search_field = params[:search_field]
      @search_term = params[:search_term]
      @members = Member.search(field: @search_field, term: @search_term).page params[:page]
    end

    def show
      @account_versions = AccountVersion.where(account_id: @member.account_ids).order(:id).reverse_order.page params[:page]
    end

    def update
      raise unless MemberTag.tags.include? params[:tag]
      if @member.tag_list.include? params[:tag]
        @member.tag_list.remove params[:tag]
      else
        @member.tag_list.add params[:tag]
      end

      @member.save

      redirect_to admin_member_path(@member)
    end

    def toggle
      if params[:api]
        @member.api_disabled = !@member.api_disabled?
      else
        @member.disabled = !@member.disabled?
      end
      @member.save
    end

    def pending_payment
      account = @member.accounts.find params[:account_id]
      tx      = PaymentTransaction.where('aasm_state != ?', 'confirmed').find_by_txid params[:payment_id]

      if tx && tx.deposit.nil? && tx.currency == account.currency
        ActiveRecord::Base.transaction do
          tx.update_attributes address: account.payment_address.address

          channel = DepositChannel.find_by_key account.currency_obj.key
          deposit = channel.kls.create!(
            payment_transaction_id: tx.id,
            blockid: tx.blockid,
            txid: tx.txid,
            amount: tx.amount,
            member: tx.member,
            account: tx.account,
            currency: tx.currency,
            confirmations: tx.confirmations,
            fund_extra: "manually by admin##{current_user.id}"
          )

          deposit.submit!
        end

        flash[:notice] = I18n.t('.success')
      else
        flash[:alert] = I18n.t('.fail')
      end

      redirect_to action: :show
    end

    def active
      @member.update_attribute(:activated, true)
      @member.save
      redirect_to admin_member_path(@member)
    end

  end
end
