class Reply < ActiveRecord::Base
  belongs_to :reslyp
  belongs_to :sender, class_name: "User", foreign_key: :sender_id
  alias_attribute :user, :sender

  validates_presence_of :reslyp
  validates_presence_of :sender
  validates_presence_of :text

  validate do |reply|
    reslyp_sender = reply.reslyp.sender
    reslyp_recipient = reply.reslyp.recipient
    unless reply.sender == reslyp_sender || reply.sender == reslyp_recipient
      errors.add(:base, "Sender is not on parent reslyp.")
    end
  end

  after_create :new_activity

  def new_activity
    return if reslyp.self_reslyp?
    recipient_user_slyp = reslyp.recipient_user_slyp
    return recipient_user_slyp.new_activity if sender_id == reslyp.sender_id
    reslyp.sender_user_slyp.new_activity
  end
end
