class UserSlypsController < BaseController
  before_action :authenticate_user!
  def create
    @slyp = Slyp.fetch(params)
    return render status: 422, json: present_model_errors(@slyp.errors),
      each_serializer: ErrorSerializer if !@slyp.valid?

    @user_slyp = current_user.user_slyps.build({:slyp_id => @slyp.id})
    if @user_slyp.save
      render status: 201, json: present(@user_slyp), serializer: UserSlypSerializer
    else
      return render status: 422, json: present_model_errors(@user_slyp.errors),
        each_serializer: ErrorSerializer if !@user_slyp.valid?
    end
  end

  def index
    @user_slyps = current_user.user_slyps
    render status: 200, json: present_collection(@user_slyps), each_serializer: UserSlypSerializer
  end

  def show
    @user_slyp = current_user.user_slyps.find(params[:id])
    render status: 200, json: present(@user_slyp), serializer: UserSlypSerializer
  end

  def destroy
    @user_slyp = current_user.user_slyps.find(params[:id])
    if @user_slyp.destroy
      head 204
    else
      head 400
    end
  end

  def update
    @user_slyp = current_user.user_slyps.find(params[:id])
    if @user_slyp.update(user_slyp_params)
      render status: 200, json: present(@user_slyp),
        serializer: UserSlypSerializer
    else
      render status: 422, json: present_model_errors(@user_slyp.errors),
        each_serializer: ErrorSerializer
    end
  end

  private

  def present(user_slyp)
    UserSlypPresenter.new user_slyp
  end

  def present_collection(user_slyps)
    user_slyps.map { |user_slyp| present(user_slyp) }
  end

  def user_slyp_params
    params.require(:user_slyp).permit(:archived, :deleted, :favourite)
  end

end
