class Document < ActiveRecord::Base
  translates :title, :body

  def to_param
    self.key
  end
end
