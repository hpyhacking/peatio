module TagHelper
  def member_tag(key)
    raise unless MemberTag.tags.include?(key)
    content_tag('span', I18n.t("tags.#{key}"), :class => "member-tag #{key}")
  end
end
