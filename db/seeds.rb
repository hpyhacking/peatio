ADMIN_EMAIL = 'admin@peatio.dev'
ADMIN_PASSWORD = 'Pass@word8'

admin_identity = Identity.find_or_create_by(email: ADMIN_EMAIL)
admin_identity.password = admin_identity.password_confirmation = ADMIN_PASSWORD
admin_identity.is_active = true
admin_identity.save!

admin_member = Member.find_or_create_by(email: ADMIN_EMAIL)
admin_member.name = 'admin'
admin_member.identity_id = admin_identity.id
admin_member.save!

if Rails.env == 'development'
  NORMAL_PASSWORD = 'Pass@word8'

  foo = Identity.create(email: 'foo@peatio.dev', password: NORMAL_PASSWORD, password_confirmation: NORMAL_PASSWORD, is_active: true)
  Member.create(email: foo.email, name: 'foo', identity_id: foo.id)

  bar = Identity.create(email: 'bar@peatio.dev', password: NORMAL_PASSWORD, password_confirmation: NORMAL_PASSWORD, is_active: true)
  Member.create(email: bar.email, name: 'bar', identity_id: bar.id)
end
