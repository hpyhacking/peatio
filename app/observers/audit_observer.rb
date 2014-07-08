class AuditObserver < ActionController::Caching::Sweeper
  def current_user
    controller ? controller.send(:current_user) : Thread.current[:user]
  end
end
