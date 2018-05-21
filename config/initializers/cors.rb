require 'grape/middleware/error'

module APIv2CORS
  def rack_response(*args)
    if env.fetch('REQUEST_URI').match?(/\A\/api\/v2\//)
      args << {} if args.count < 3
      APIv2::CORS.call(args[2])
    end
    super(*args)
  end
end

Grape::Middleware::Error.prepend APIv2CORS
