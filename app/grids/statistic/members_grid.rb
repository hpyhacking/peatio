module Statistic
  class MembersGrid
    include Datagrid
    include Datagrid::Naming
    include Datagrid::ColumnI18n

    scope do
      Identity.includes(:member).order('identities.created_at DESC')
    end

    filter :sn do |value| where('members.sn = ?', value) end
    filter :email do |value| where('members.email like ?', "%#{value}%") end
    filter(:is_active, :enum, :select => [[I18n.t('yes'), 1], [I18n.t('no'), 0]])

    column(:id)
    column(:email)
    column(:sn) do |asset|
      asset.member.try(:sn)
    end
    column_localtime :created_at
    column(:is_active) do |identity|
      format(identity) do |identity|
        identity.is_active ? t('yes') : t('no')
      end
    end
    column(:action) do |asset|
      format(asset) do |asset|
        if asset.is_active && asset.member
          link_to t("actions.detail"), admin_member_path(asset.member.id)
        end
      end
    end
  end
end
