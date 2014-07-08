module ControllerObserver
  extend ActiveSupport::Concern

  module ClassMethods #:nodoc:
    def observer(*observers)
      configuration = observers.extract_options!

      observers.each do |observer|
        observer_instance = (observer.is_a?(Symbol) ? Object.const_get(observer.to_s.classify) : observer).instance
        around_filter(observer_instance, only: configuration[:only])
      end
    end
  end
end
