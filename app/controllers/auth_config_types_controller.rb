class AuthConfigTypesController < ApplicationController
  before_action :check_admin

  def index
    @auth_config_types = AuthConfigType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @auth_config_types }
    end
  end

  def show
    @auth_config_type = AuthConfigType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @auth_config_type }
    end
  end

  def new
    @auth_config_type = AuthConfigType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @auth_config_type }
    end
  end

  def edit
    @auth_config_type = AuthConfigType.find(params[:id])
  end

  def create
    @auth_config_type = AuthConfigType.new(auth_config_type_params)

    respond_to do |format|
      if @auth_config_type.save
        format.html { redirect_to @auth_config_type, notice: 'Auth config type was successfully created.' }
        format.json { render json: @auth_config_type, status: :created, location: @auth_config_type }
      else
        format.html { render action: "new" }
        format.json { render json: @auth_config_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @auth_config_type = AuthConfigType.find(params[:id])

    respond_to do |format|
      if @auth_config_type.update(auth_config_type_params)
        format.html { redirect_to @auth_config_type, notice: 'Auth config type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auth_config_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @auth_config_type = AuthConfigType.find(params[:id])
    @auth_config_type.destroy

    respond_to do |format|
      format.html { redirect_to auth_config_types_url }
      format.json { head :no_content }
    end
  end

  private

  def auth_config_type_params
    params.require(:auth_config_type).permit(:code, :name, :description)
  end
end
