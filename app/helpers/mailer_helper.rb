module MailerHelper
  def mailer_signature
    %w(thanks team).map do |key|
      I18n.t("mailer.signature.#{key}")
    end.join("\n")
  end
end
