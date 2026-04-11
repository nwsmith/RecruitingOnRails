class UsersController < ApplicationController
  before_action :check_admin

  # Columns that must never appear in any JSON response. password_digest
  # is the bcrypt hash; api_key_digest is the HMAC of the bearer-auth
  # secret. Both are credentials and would be useful to an attacker who
  # got read access to the JSON API.
  JSON_EXCLUDE = %i[password_digest api_key_digest].freeze

  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users.as_json(except: JSON_EXCLUDE) }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user.as_json(except: JSON_EXCLUDE) }
    end
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user.as_json(except: JSON_EXCLUDE) }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render json: @user.as_json(except: JSON_EXCLUDE), status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # POST /users/:id/regenerate_api_key
  #
  # Issues a fresh API key, stores its HMAC digest, and renders the
  # plaintext to the admin exactly once via flash. The plaintext is not
  # stored anywhere — if the admin doesn't capture it from this response,
  # they have to regenerate again.
  def regenerate_api_key
    @user = User.find(params[:id])
    plaintext = @user.regenerate_api_key!

    respond_to do |format|
      format.html do
        flash[:notice] = "New API key for #{@user.name}: #{plaintext} " \
                         "(this is shown only once — capture it now)"
        redirect_to @user
      end
      format.json { render json: { api_key: plaintext } }
    end
  end

  private

  # Permits role-flag attributes (:admin, :manager, :hr) which Brakeman
  # flags as a mass-assignment risk by default. The risk is real in
  # general — letting users grant themselves admin via a form post —
  # but this controller is gated to admin-only via `before_action
  # :check_admin`, so only existing admins can reach the create/update
  # actions in the first place. The whole point of this controller IS
  # admin role management.
  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :user_name, :auth_name,
      :active, :admin, :manager, :hr, :auth_config_id,
      :password, :password_confirmation
    )
  end
end
