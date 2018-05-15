# encoding: UTF-8
# frozen_string_literal: true

Kaminari.configure do |config|
  config.default_per_page = 10
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end

module KaminariCustomRoute
  def page_url_for(page)
    params = params_for(page).symbolize_keys
    route  = params.delete(:route)

    if route
      @template.send("#{route}_url", params)
    else
      @template.url_for(params)
    end
  end
end

Kaminari::Helpers::Tag.prepend KaminariCustomRoute
