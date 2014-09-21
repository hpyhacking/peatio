module PusherSync

  def self.included(base)
    base.class_eval do
      after_update :sync_update
      after_create :sync_create
      after_destroy :sync_destroy
    end
  end

  private

  def sync_update
    ::Pusher["private-#{self.sn}"].trigger_async(event, { type: 'update', id: self.id, attributes: self.changes_attributes_as_json })
  end

  def sync_create
    ::Pusher["private-#{self.sn}"].trigger_async(event, {type: 'create', attributes: self.as_json })
  end

  def sync_destroy
    ::Pusher["private-#{self.sn}"].trigger_async(event, {type: 'destroy', id: self.id })
  end

  def event
    self.class.name.underscore.pluralize
  end

end
