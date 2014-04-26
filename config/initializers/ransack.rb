module Ransack
  module Helpers
    module FormHelper
      def search_form_for_with_default_url_opt(record, options = {}, &proc)
        options[:url] = ''
        options[:wrapper] = 'search'
        search_form_for_without_default_url_opt(record, options, &proc)
      end

      alias_method_chain :search_form_for, :default_url_opt
    end
  end
end
