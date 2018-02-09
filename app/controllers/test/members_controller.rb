module Test
  class MembersController < ModuleController
    def index
      Member.select(:id, :email).order(:id).map do |member|
        { id:       member.id,
          email:    member.email,
          jwt:      member.jwt,
          role:     member.admin? ? 'admin' : 'member' }
      end.tap { |members| render json: { members: members } }
    end
  end
end
