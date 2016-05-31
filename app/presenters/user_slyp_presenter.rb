class UserSlypPresenter < BasePresenter
  attr_accessor :user_slyp, :slyp

  delegate :title, :duration, :site_name, :author, :url, :slyp_type,
           :html, :description, to: :slyp
  delegate :id, :archived, :favourite, :deleted, :slyp_id, :friends,
            :total_favourites, :latest_conversation, :total_reslyps,
           :unseen, :unseen_activity, :unseen_replies, to: :user_slyp

  def initialize(user_slyp)
    @user_slyp = user_slyp
    @slyp = Slyp.find(@user_slyp.slyp_id)
  end

  def display_url
    display_url = @slyp.display_url
    invalid_exts = %w(data:image .jpg .jpeg .png .gif .ico)
    invalid = (display_url.nil? ||
      !invalid_exts.any? { |ext| display_url.include?(ext) })
    invalid ? "/assets/logo.png" : display_url
  end
end
