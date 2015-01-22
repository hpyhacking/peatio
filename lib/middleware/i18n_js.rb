module Middleware
  class I18nJs
    def initialize(app)
      @app = app
    end

    def call(env)
      update_cache(env['ORIGINAL_FULLPATH']) if matching?(env['ORIGINAL_FULLPATH'])
      @app.call(env)
    end

    private

    def matching?(path)
      path =~ /^\/assets\/locales\/[a-z\-A-Z]*\.js/
    end

    def cache_dir
      @cache_dir ||= Rails.root.join("public/assets/locales")
    end

    def update_cache(path)
      locale = path.scan(/[a-z\-A-Z]*\.js/).first.gsub('.js', '')
      file_path = "#{cache_dir}/#{locale}.js"

      FileUtils.mkdir_p(cache_dir)
      File.open(file_path, "w+") do |file|
        file << JsLocaleHelper.output_locale(locale)
      end
    end
  end
end
