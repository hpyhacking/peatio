# encoding: UTF-8
# frozen_string_literal: true

# Full list of roles abilities could be found on docs/roles.md
module Abilities

  class << self
    def new(member)
      if member.role.in?(Member::ADMIN_ROLES)
        "Abilities::#{member.role.capitalize}".constantize.new
      end
    end
  end
end
