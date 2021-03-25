# frozen_string_literal: true

module API
  module V2
    module Admin
      class InternalTransfers < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Get all internal transfers.',
             is_array: true,
             success: API::V2::Admin::Entities::InternalTransfer
        params do
          optional :sender,
            values:  { value: -> (v) { Member.where('uid = ? OR username = ?', v, v).present? }, message: 'admin.receiver.doesnt_exist' },
            desc: 'Sender uid or username.'
          optional :receiver,
            values:  { value: -> (v) { Member.where('uid = ? OR username = ?', v, v).present? }, message: 'admin.receiver.doesnt_exist' },
            desc: 'Receiver uid or username.'
          use :currency
          use :pagination
          use :date_picker
          use :ordering
        end
        get '/internal_transfers' do
          admin_authorize! :read, ::InternalTransfer

          if params[:sender].present?
            sender = Member.find_by('uid = ? OR username = ?', params[:sender], params[:sender])
            params.except!(:sender).merge!(sender_id: sender.id) if sender.present?
          end

          if params[:receiver].present?
            receiver = Member.find_by('uid = ? OR username = ?', params[:receiver], params[:receiver])
            params.except!(:receiver).merge!(receiver_id: receiver.id) if receiver.present?
          end

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:sender_id, :receiver_id)
                             .translate_in(currency: :currency_id)
                             .with_daterange
                             .build

          search = ::InternalTransfer.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::InternalTransfer
        end
      end
    end
  end
end
