module Backstore
  class UsersController < BaseController
    load_and_authorize_resource

    before_action :prevent_self_role_change, only: :update
    before_action :prevent_manager_assign_admin, only: %i[create update]

    def index
      @users = User.all

      @users = @users.with_status(params[:status])
      @users = @users.with_role(params[:role])
      @users = @users.search_by_email(params[:q])

      # Paginación con per_page dinámico
      per_page = params[:per_page] == "all" ? @users.count : (params[:per_page] || 25).to_i
      @users = @users.order(id: :asc).page(params[:page]).per(per_page)
    end

    def new
      @user = User.new
    end

    def edit; end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to backstore_users_path, notice: "Usuario creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      sanitized_params = user_params.dup

      # Si password viene vacío, eliminarlo para que Devise NO lo valide
      if sanitized_params[:password].blank?
        sanitized_params.delete(:password)
        sanitized_params.delete(:password_confirmation)
      end

      if @user.update(sanitized_params)
        redirect_to backstore_users_path, notice: "Usuario actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to backstore_users_path, alert: "No podés eliminar tu propia cuenta."
        return
      end

      @user.destroy
      redirect_to backstore_users_path, notice: "Usuario eliminado correctamente."
    end

    def restore
      if @user.restore
        redirect_to backstore_users_path, notice: "Usuario restaurado correctamente."
      else
        redirect_to backstore_users_path, alert: "No se pudo restaurar el usuario."
      end
    end

    private

    # Nadie puede cambiar su propio rol
    def prevent_self_role_change
      return unless @user == current_user

      return unless params[:user][:role] && params[:user][:role] != @user.role

      redirect_to backstore_users_path,
                  alert: "No podés cambiar tu propio rol."
    end

    # Un gerente NO puede asignar ni cambiar un rol a administrador
    def prevent_manager_assign_admin
      return unless current_user.manager?

      return unless params[:user][:role] == "admin"

      redirect_to backstore_users_path,
                  alert: "Un gerente no puede asignar el rol de administrador."
    end

    def user_params
      params
        .require(:user)
        .permit(:email, :password, :password_confirmation, :role)
    end
  end
end