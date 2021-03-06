class ReslypsController < BaseController
  before_action :authenticate_user!

  def create
    return render_400 unless [:emails, :slyp_id, :comment].all? { |s| params.key? s }
    @user_slyp = current_user.user_slyps.find_or_create_by(
      slyp_id: params.delete(:slyp_id))
    @reslyps = @user_slyp.send_slyps(params[:emails], params[:comment])
    return render_422(reslyp) unless touch_user_slyps
    render status: 201, json: present_collection(@reslyps),
           each_serializer: ReslypSerializer
  end

  def index
    return render_400 unless params.key? :id
    user_slyp = current_user.user_slyps.find(params[:id])
    user_slyp.update_attribute(:unseen_activity, false)
    @reslyps = user_slyp.reslyps.includes(:replies, :sender, :recipient).reverse
    render status: 200, json: present_collection(@reslyps),
           each_serializer: ReslypSerializer
  end

  def show
    @reslyp = current_user.reslyps.find(params[:id])
    render status: 200, json: present(@reslyp), serializer: ReslypSerializer
  end

  private

  def present(reslyp)
    ReslypPresenter.new reslyp, current_user
  end

  def present_collection(reslyps)
    reslyps.map { |reslyp| present(reslyp) }
  end

  def touch_user_slyps
    @user_slyp.touch
    @reslyps.each do |reslyp|
      reslyp.recipient_user_slyp.touch
      return false unless reslyp.valid?
    end
    true
  end
end
