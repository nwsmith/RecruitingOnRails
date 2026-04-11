class RegistriesController < ApplicationController
  before_action :check_admin

  def index
    @registries = Registry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registries }
    end
  end

  def show
    @registry = Registry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registry }
    end
  end

  def new
    @registry = Registry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @registry }
    end
  end

  def edit
    @registry = Registry.find(params[:id])
  end

  def create
    @registry = Registry.new(registry_params)

    respond_to do |format|
      if @registry.save
        format.html { redirect_to @registry, notice: 'Registry was successfully created.' }
        format.json { render json: @registry, status: :created, location: @registry }
      else
        format.html { render action: "new" }
        format.json { render json: @registry.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @registry = Registry.find(params[:id])

    respond_to do |format|
      if @registry.update(registry_params)
        format.html { redirect_to @registry, notice: 'Registry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @registry.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @registry = Registry.find(params[:id])
    @registry.destroy

    respond_to do |format|
      format.html { redirect_to registries_url }
      format.json { head :no_content }
    end
  end

  private

  def registry_params
    params.require(:registry).permit(:key, :value)
  end
end
