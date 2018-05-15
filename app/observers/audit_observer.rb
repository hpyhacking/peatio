# encoding: UTF-8
# frozen_string_literal: true

class AuditObserver < ActiveRecord::Observer
  def current_user
    Member.current
  end
end
