module TagHelper
  def member_tag(key)
    raise unless MemberTag.tags.include?(key)
    content_tag('span', I18n.t("tags.#{key}"), :class => "member-tag #{key}")
  end

  def admin_asset_tag(asset)
    return if asset.blank?

    if asset.image?
      link_to image_tag(asset.file.url, style: 'max-width:500px;max-height:500px;'), asset.file.url, target: '_blank'
    else
      link_to asset['file'], asset.file.url
    end
  end
end
