# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def new_user_beta
    UserMailer.new_user_beta(User.first)
  end

  def reslyp_friend
    UserMailer.reslyp_friend(Reslyp.first)
  end

  def reslyp_email_contact
    user_slyp = UserSlyp.first
    invitee = FactoryGirl.create(:user)
    invitee.invite! do |u|
      u.skip_invitation = true
    end
    reslyp = user_slyp.send_slyp(invitee.email, "comment")
    UserMailer.reslyp_email_contact(reslyp)
  end

  def activity
    UserMailer.activity(User.with_activity.first)
  end

  def new_friend_notification
    user = User.first
    friend = user.friends.first
    UserMailer.new_friend_notification(user, friend)
  end
end
