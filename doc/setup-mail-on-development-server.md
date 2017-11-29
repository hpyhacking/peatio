Setup mail(SMTP) for peatio on development server 
-------------------------------------
## Prerequisite
* SMTP Server details (To setup new SMTP server on Mailgun, Follow this steps: https://support.cloudways.com/configure-mailgun-smtp/)

### Update smtp and email config to `config/application.yml`
    
    SMTP_PORT: 465 # could be 465, 587
    SMTP_DOMAIN: <DOMAIN_NAME>
    SMTP_ADDRESS: <SMTP_ADDRESS>
    SMTP_USERNAME: <SMTP_USERNAME>
    SMTP_PASSWORD: <SMTP_PASSWORD>
    SMTP_AUTHENTICATION: plain # could be plain, login or cram_md5

    SUPPORT_MAIL: <SUPPORT_EMAIL_ID>
    SYSTEM_MAIL_FROM: <FROM_EMAIL_ID>
    SYSTEM_MAIL_TO: <SYSTEM_EMAIL_ID>
    OPERATE_MAIL_TO: <OPERATE_EMAIL_ID>
    
#### Want to send mail using your Gmail account 
    SMTP_PORT: 587 
    SMTP_DOMAIN: gmail.com
    SMTP_ADDRESS: smtp.gmail.com
    SMTP_USERNAME: <GMAIL_USERNAME>
    SMTP_PASSWORD: <GMAIL_PASSWORD>
    SMTP_AUTHENTICATION: plain
    
### Delete following lines from `config/environments/development.rb` to remove action mailer file config

    config.action_mailer.raise_delivery_errors = false
    config.action_mailer.delivery_method = :file
    config.action_mailer.file_settings = { location: 'tmp/mails' }
    config.action_mailer.default_url_options = { :host => ENV["URL_HOST"] }
    
### Add action mailer config to `config/environments/development.rb` 

    config.action_mailer.default_url_options = { host: ENV["URL_HOST"], protocol: ENV['URL_SCHEMA'] }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      port:           ENV["SMTP_PORT"],
      domain:         ENV["SMTP_DOMAIN"],
      address:        ENV["SMTP_ADDRESS"],
      user_name:      ENV["SMTP_USERNAME"],
      password:       ENV["SMTP_PASSWORD"],
      authentication: ENV["SMTP_AUTHENTICATION"],
      enable_starttls_auto: true,
      tls: true,
      openssl_verify_mode: 'none'
    }


