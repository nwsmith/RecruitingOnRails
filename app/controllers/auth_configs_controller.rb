class AuthConfigsController < ApplicationController
  before_action :check_admin

  # GET /auth_configs
  # GET /auth_configs.json
  def index
    @auth_configs = AuthConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @auth_configs }
    end
  end

  # GET /auth_configs/1
  # GET /auth_configs/1.json
  def show
    @auth_config = AuthConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @auth_config }
    end
  end

  # GET /auth_configs/new
  # GET /auth_configs/new.json
  def new
    @auth_config = AuthConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @auth_config }
    end
  end

  # GET /auth_configs/1/edit
  def edit
    @auth_config = AuthConfig.find(params[:id])
  end

  # POST /auth_configs
  # POST /auth_configs.json
  def create
    @auth_config = AuthConfig.new(user_params)

    respond_to do |format|
      if @auth_config.save
        format.html { redirect_to @auth_config, notice: 'Auth config was successfully created.' }
        format.json { render json: @auth_config, status: :created, location: @auth_config }
      else
        format.html { render action: "new" }
        format.json { render json: @auth_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /auth_configs/1
  # PUT /auth_configs/1.json
  def update
    @auth_config = AuthConfig.find(params[:id])

    respond_to do |format|
      if @auth_config.update_attributes(user_params)
        format.html { redirect_to @auth_config, notice: 'Auth config was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auth_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auth_configs/1
  # DELETE /auth_configs/1.json
  def destroy
    @auth_config = AuthConfig.find(params[:id])
    @auth_config.destroy

    respond_to do |format|
      format.html { redirect_to auth_configs_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:auth_config).permit!
  end
end
