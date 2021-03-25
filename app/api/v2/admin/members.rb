# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Members < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Get all members, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Member
        params do
          optional :state,
                   desc: 'Filter order by state.'
          optional :role,
                   values: { value: -> { ::Ability.roles }, message: 'admin.member.invalid_role' }
          optional :group,
                   values: { value: -> { ::Member.groups }, message: 'admin.member.invalid_group' }
          optional :email,
                   desc: -> { API::V2::Entities::Member.documentation[:email][:desc] }
          use :uid
          use :date_picker
          use :pagination
          use :ordering
        end
        get '/members' do
          admin_authorize! :read, ::Member

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:uid, :email, :state, :role, :group)
                             .with_daterange
                             .build

          search = Member.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"
          present paginate(search.result), with: API::V2::Admin::Entities::Member
        end

        desc 'Get available members groups.',
          is_array: true
        get '/members/groups' do
          admin_authorize! :read, ::Member

          Member.groups
        end

        desc 'Get a member.' do
          success API::V2::Admin::Entities::Member
        end
        params do
          requires :uid,
                   type: String,
                   desc: 'The shared user ID.'
        end
        get '/members/:uid' do
          admin_authorize! :read, ::Member

          present Member.find_by!(uid: params[:uid]), with: API::V2::Admin::Entities::Member
        end

        desc 'Set user group.' do
          success API::V2::Admin::Entities::Member
        end
        params do
          requires :uid,
                   type: String,
                   desc: 'The shared user ID.'
          requires :group,
                   type: String,
                   coerce_with: ->(v) { v.strip.downcase },
                   desc: 'User gruop'
        end
        put '/members/:uid' do
          admin_authorize! :update, ::Member
          declared_params = declared(params)

          member = Member.find_by!(uid: declared_params[:uid])
          if member.update(group: declared_params[:group])
            present member, with: API::V2::Admin::Entities::Member
            status 201
          else
            body errors: member.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
