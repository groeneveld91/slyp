desc "Notifies users of unseen activity on user_slyps"
task activity_notifications: :environment do
  User.with_activity.each do |user|
    send_today = (Time.now.sunday? || Time.now.wednesday? || Time.now.saturday?)
    if user.notify_activity && user.active? && send_today
      UserMailer.activity(user).deliver_later
    end
  end
end

desc "Outreach email #1 for activated users -- Meet Slyp Beta"
task activated_outreach_one: :environment do
  User.where("activated_at <= ?", 1.day.ago).each do |user|
    next if user.activated_outreached_one?
    user.send_activated_outreach_one if user.active?
  end
end

desc "Outreach email #2 for activated users -- How Slyp works"
task activated_outreach_two: :environment do
  User.where("activated_at <= ?", 3.days.ago).each do |user|
    next if user.activated_outreached_two?
    user.send_activated_outreach_two if user.active?
  end
end

desc "Outreach email #1 for invited users"
task invited_outreach_one: :environment do
  User.where("invitation_sent_at <= ?", 3.day.ago).each do |user|
    User.invite!({ email:user.email }, user.invited_by) if user.invited?
  end
end


