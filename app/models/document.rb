class Document < ActiveRecord::Base
  def to_param
    self.key
  end
end
