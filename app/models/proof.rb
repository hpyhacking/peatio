class Proof < ActiveRecord::Base

  serialize :root
  validates_presence_of :root

  def ready!
    self.ready = true
    save!
  end

end
