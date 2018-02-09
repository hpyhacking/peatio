# Testing mailer in development environment

Peatio's development environment is configured to send emails to MailCatcher's server so you can use friendly UI for viewing send emails.

## How does it work?

1. Install MailCatcher by running the command `gem install mailcatcher`.
2. Run MailCatcher by running the command `mailcatcher`.
3. Send some emails.
4. Open [http://localhost:1080](http://localhost:1080) in your browser and you should see sent emails.

Use `mailcatcher --help` to see the command line options.
