namespace :notifications do
  task send: :environment do
    target_users = User.where(receive_email_notifications: true)
    logs = []
    now = Time.zone.now
    target_users.find_each do |u|
      u.events.each do |evt|
        if now < evt.start && now + 1.hour >= evt.start
          logs << "[#{now.strftime('%d/%m/%Y %H:%M')}] #{u.email} receive notification about event #{evt.title}"

          EventNotificationMailer.notify_user(u, evt).deliver_now
        end
      end
    end
    if logs.any?
      issue_to_file('tmp/email_sending_test.txt', logs)
    end
  end

  def issue_to_file(filename, logs)
    File.open(filename, 'a') do |f|
      f.write("\n\n")
      f.write(logs.join("\n"))
    end
  end
end