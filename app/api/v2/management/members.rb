module API
  module V2
    module Management
      class Members < Grape::API

        desc 'Create a member.' do
          @settings[:scope] = :write_members
        end
        params do
          requires :email,
                   type: String,
                   desc: 'User email.'
          requires :uid,
                   type: String,
                   desc: 'The shared user ID.'
          requires :level,
                   type: Integer,
                   desc: 'User level.'
          requires :role,
                   type: String,
                   desc: 'User role.'
          requires :state,
                   type: String,
                   desc: 'User state.'
          requires :group,
                   type: String,
                   desc: 'User group'
        end
        post '/members' do
          declared_params = declared(params)

          member = Member.create!(declared_params)
          present member, with: Entities::Member
          status 200
        rescue ActiveRecord::RecordInvalid => e
          body errors: e.message
          status 422
        end

        desc 'Set user group.' do
          @settings[:scope] = :write_members
        end
        params do
          requires :uid,
                   type: String,
                   desc: 'The shared user ID.'
          requires :group,
                   type: String,
                   desc: 'User gruop'
        end
        post '/members/group' do
          declared_params = declared(params)

          member = Member.find_by!(uid: declared_params[:uid])
          member.update!(group: declared_params[:group])
          present member, with: Entities::Member
          status 200
        rescue ActiveRecord::RecordInvalid => e
          body errors: e.message
          status 422
        end
      end
    end
  end
end
