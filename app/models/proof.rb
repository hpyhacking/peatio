class Proof < ActiveRecord::Base
  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true

  serialize :root
  validates_presence_of :root, :currency

  scope :current, lambda { order('id desc').first }

  def ready!
    self.ready = true
    save!
  end

  def timestamp
    root['timestamp'] || updated_at.to_s
  end

end
