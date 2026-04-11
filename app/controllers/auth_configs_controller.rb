class AuthConfigsController < ApplicationController
  before_action :check_admin

  def index
    @auth_configs = AuthConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @auth_configs }
    end
  end

  def show
    @auth_config = AuthConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @auth_config }
    end
  end

  def new
    @auth_config = AuthConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @auth_config }
    end
  end

  def edit
    @auth_config = AuthConfig.find(params[:id])
  end

  def create
    @auth_config = AuthConfig.new(auth_config_params)

    respond_to do |format|
      if @auth_config.save
        format.html { redirect_to @auth_config, notice: "Auth config was successfully created." }
        format.json { render json: @auth_config, status: :created, location: @auth_config }
      else
        format.html { render action: "new" }
        format.json { render json: @auth_config.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @auth_config = AuthConfig.find(params[:id])

    respond_to do |format|
      if @auth_config.update(auth_config_params)
        format.html { redirect_to @auth_config, notice: "Auth config was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auth_config.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @auth_config = AuthConfig.find(params[:id])
    @auth_config.destroy

    respond_to do |format|
      format.html { redirect_to auth_configs_url }
      format.json { head :no_content }
    end
  end

  private

  def auth_config_params
    params.require(:auth_config).permit(:name, :auth_config_type_id, :server, :port, :ldap_base, :ldap_domain)
  end
end
