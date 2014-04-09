module APIv2
  module SmartDoc
    class <<self
      def included(base)
        base.routes.each do |route|
          route.route_params.each do |param, options|
            if args = map_doc(param)
              options.reverse_merge! find_doc(*args)
            end
          end
        end
      end

      def find_doc(entity, attr)
        ::APIv2::Entities.const_get(entity).documentation[attr]
      end

      def map_doc(param)
        case param
        when 'market'
          ['Market', :id]
        when 'side', 'orders[side]'
          ['Order', :side]
        when 'volume', 'orders[volume]'
          ['Order', :volume]
        when 'price', 'orders[price]'
          ['Order', :price]
        end
      end

    end
  end
end
