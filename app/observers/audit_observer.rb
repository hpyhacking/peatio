class AuditObserver < ActiveRecord::Observer
  def current_user
    Member.current
  end
end
