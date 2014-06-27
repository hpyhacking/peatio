class ActionView::TestCase::TestController
  def default_url_options(options={})
    { :lang => :en }
  end
end

class ActionDispatch::Routing::RouteSet
  def default_url_options(options={})
    { :lang => :en }
  end
end
