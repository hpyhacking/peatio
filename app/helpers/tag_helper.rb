module TagHelper
  def member_tag(key)
    raise unless BaseConfig.member.tags.include?(key)
    content_tag('span', I18n.t("tags.#{key}"), :class => "member-tag #{key}")
  end
end
