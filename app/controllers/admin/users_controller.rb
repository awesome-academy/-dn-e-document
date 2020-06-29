class Admin::UsersController < AdminController
  load_and_authorize_resource params_method: :user_params, except: :export_download
  before_action :check_role_admin, :check_ban, only: :update

  def index
    @search = User.search(params[:q])
    @users = @search.result.sort_by_name.paginate page: params[:page], per_page: Settings.per_page
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "success.update_user"
    else
      flash[:danger] = t "error.update_user"
    end
    redirect_to request.referer
  end

  def export
    respond_to do |format|
      format.json do
        job_id = ExportUserWorker.perform_async
        render json: {
          jid: job_id
        }
      end
    end
  end

  def export_status
    respond_to do |format|
      format.json do
        job_id = params[:job_id]
        job_status = Sidekiq::Status.get_all(job_id).symbolize_keys
        render json: {
          status: job_status[:status],
          percentage: job_status[:pct_complete]
        }
      end
    end
  end

  def export_download
    job_id = params[:id]
    exported_file_name = "users_export_#{job_id}.xlsx"
    filename = "UserData_#{DateTime.now.strftime(Settings.format_file_name)}.xlsx"
    respond_to do |format|
      format.xlsx do
        send_file Rails.root.join("tmp", exported_file_name), filename: filename
      end
    end
  end

  private

  def user_params
    params.require(:user)
          .permit :role, :active
  end

  def check_role_admin
    return unless @user.admin? && (params[:user][:role] == Settings.role_member || params[:user][:active] == Settings.false_string)

    flash[:danger] = t "error.edit_admin"
    redirect_to request.referer
  end

  def check_ban
    @user.send_block_email if params[:user][:active] == Settings.false_string
  end
end
