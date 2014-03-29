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
    Time.at(root['timestamp']/1000) || updated_at
  end

end
