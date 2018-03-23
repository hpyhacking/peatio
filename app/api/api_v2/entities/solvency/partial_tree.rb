module APIv2
  module Entities
    module Solvency
      class PartialTree < Base
        expose :id
        expose(:partial_tree) { |p| p.json['partial_tree'] }
        expose :sum
        expose :created_at
      end
    end
  end
end

