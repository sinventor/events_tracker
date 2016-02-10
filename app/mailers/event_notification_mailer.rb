class EventNotificationMailer < ApplicationMailer
  def notify_user(user, event)
    @user = user
    @event = event
    mail(to: user.email, subject: 'Событие скоро наступает!')
  end
end
