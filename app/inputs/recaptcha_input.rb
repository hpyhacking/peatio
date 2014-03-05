class RecaptchaInput < SimpleForm::Inputs::Base
  def input
    template.recaptcha_tags :display => {:theme => 'white'}, :attribute => :recaptcha
  end
end
