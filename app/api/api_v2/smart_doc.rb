module APIv2
  module SmartDoc
    class <<self
      def included(base)
        base.routes.each do |route|
          route.route_params.each do |param, options|
            if doc = find_doc(param)
              options.reverse_merge! doc
            end
          end
        end
      end

      def find_doc(param)
        case param
        when 'market'
          ::APIv2::Entities::Market.documentation[:id]
        when 'side', 'orders[side]'
          ::APIv2::Entities::Order.documentation[:side]
        when 'volume', 'orders[volume]'
          ::APIv2::Entities::Order.documentation[:volume]
        when 'price', 'orders[price]'
          ::APIv2::Entities::Order.documentation[:price]
        end
      end

    end
  end
end
