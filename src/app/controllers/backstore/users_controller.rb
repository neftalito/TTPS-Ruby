module Backstore
  class UsersController < BaseController
    load_and_authorize_resource

    before_action :redirect_self_edit_to_account_settings, only: :edit
    before_action :redirect_self_update_to_account_settings, only: :update
    before_action :prevent_self_role_change, only: :update
    before_action :prevent_manager_assign_admin, only: %i[create update]

    def index
      @users = @users.with_status(params[:status])
      @users = @users.with_role(params[:role])
      @users = @users.search_by_email(params[:q])

      per_page = sanitized_per_page(
        params[:per_page],
        default: DEFAULT_BACKSTORE_PER_PAGE,
        max: MAX_BACKSTORE_PER_PAGE
      )
      @users = @users.order(id: :asc).page(params[:page]).per(per_page)
    end

    def new; end

    def edit; end

    def create
      if @user.save
        redirect_to backstore_users_path, notice: I18n.t("flash.backstore.users.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      sanitized_params = user_params.dup

      if sanitized_params[:password].blank?
        sanitized_params.delete(:password)
        sanitized_params.delete(:password_confirmation)
      end

      if @user.update(sanitized_params)
        redirect_to backstore_users_path, notice: I18n.t("flash.backstore.users.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to backstore_users_path, alert: I18n.t("flash.backstore.users.delete_self")
        return
      end

      @user.destroy
      redirect_to backstore_users_path, notice: I18n.t("flash.backstore.users.deleted")
    end

    def restore
      if @user.restore
        redirect_to backstore_users_path, notice: I18n.t("flash.backstore.users.restored")
      else
        redirect_to backstore_users_path, alert: I18n.t("flash.backstore.users.restore_failed")
      end
    end

    private

    def redirect_self_edit_to_account_settings
      return unless @user == current_user

      redirect_to edit_user_registration_path
    end

    def redirect_self_update_to_account_settings
      return unless @user == current_user

      redirect_to edit_user_registration_path, alert: I18n.t("flash.backstore.users.edit_self_via_profile")
    end

    def prevent_self_role_change
      return unless @user == current_user
      return unless params[:user][:role] && params[:user][:role] != @user.role

      redirect_to backstore_users_path,
                  alert: I18n.t("flash.backstore.users.update_self_role")
    end

    def prevent_manager_assign_admin
      return unless current_user.manager?
      return unless params[:user][:role] == "admin"

      redirect_to backstore_users_path,
                  alert: I18n.t("flash.backstore.users.manager_cannot_assign_admin")
    end

    def user_params
      params
        .require(:user)
        .permit(:email, :password, :password_confirmation, :role)
    end
  end
end
