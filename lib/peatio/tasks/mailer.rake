namespace :peatio do
  namespace :mailer do
    #
    # Usage:
    #   RECIPIENT=eahome00@gmail.com bundle exec rake peatio:mailer:testshot
    #
    desc 'Send test email'
    task testshot: :environment do
      Mailer = Class.new ActionMailer::Base do
        default from: 'admin@peatio.tech'

        def testshot
          mail to: ENV.fetch('RECIPIENT'), subject: 'Peatio Testshot E-Mail' do |format|
            format.text { render text: 'Hello, world!'}
          end
        end
      end

      Mailer.testshot.deliver_now
    end
  end
end
