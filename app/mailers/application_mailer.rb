class ApplicationMailer < ActionMailer::Base
  default from: "notifications@eventstacker.com"
  layout 'mailer'
end
