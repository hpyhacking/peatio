class MembersController < ApplicationController
  layout 'dialog'

  before_filter :auth_member!
  before_filter :auth_no_initial!

  def edit
    @member = current_user
  end

  def update
    @member = current_user

    ActiveRecord::Base.transaction do
      if @member.update_attributes(member_params)
        account = @member.get_account(:cny)
        account.withdraw_addresses.create(
          :is_locked => true,
          :label => @member.name,
          :address => @member.alipay,
          :category => :alipay)
        redirect_to root_path
      else
        render :edit
      end
    end
  end

  private
  def member_params
    # auto generate member pin code
    params[:member][:sn] = Member.only_sn
    params.required(:member).permit(:sn, :alipay, :name)
  end
end
