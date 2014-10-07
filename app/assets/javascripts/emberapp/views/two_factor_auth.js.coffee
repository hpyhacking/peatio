Peatio.TwoFactorAuthView = Ember.View.extend({
  templateName: 'two_factor_auth',
  didInsertElement: ->
    TwoFactorAuth.attachTo('.two-factor-auth-container')
})

