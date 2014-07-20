# == Schema Information
#
# Table name: assets
#
#  id              :integer          not null, primary key
#  type            :string(255)
#  attachable_id   :integer
#  attachable_type :string(255)
#  file            :string(255)
#

class Asset < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  mount_uploader :file, FileUploader

  def image?
    file.content_type.start_with?('image') if file?
  end
end

class Asset::IdDocumentFile < Asset
end

class Asset::IdBillFile < Asset
end
