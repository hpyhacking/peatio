module TagHelper
  def admin_asset_tag(asset)
    return if asset.blank?

    if asset.image?
      link_to image_tag(asset.file.url, style: 'max-width:500px;max-height:500px;'), asset.file.url, target: '_blank'
    else
      link_to asset['file'], asset.file.url
    end
  end

  def bank_code_to_name(code)
    I18n.t("banks.#{code}")
  end
end