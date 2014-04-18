class Proof < ActiveRecord::Base
  include Currencible

  has_many :partial_trees

  serialize :root
  validates_presence_of :root, :currency

  def ready!
    self.ready = true
    save!
  end

  def timestamp
    Time.at(root['timestamp']/1000) || updated_at
  end

  def partial_tree_of(account)
    partial_trees.where(account: account).first
  end

end
