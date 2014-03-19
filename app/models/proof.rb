class Proof < ActiveRecord::Base

  serialize :root
  validates_presence_of :root

  scope :current, lambda { order('id desc').first }

  def ready!
    self.ready = true
    save!
  end

end
