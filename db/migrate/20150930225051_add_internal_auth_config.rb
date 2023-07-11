class AddInternalAuthConfig < ActiveRecord::Migration[7.0]
  def up
    auth_config_type = AuthConfigType.where(code: 'INTERNAL').uniq[0]
    #auth_config_type = AuthConfigType.find_all_by_code('INTERNAL')[0]
    AuthConfig.create({:auth_config_type => auth_config_type, :name => "Default Setup"})
  end

  def down
    auth_config = AuthConfig.find_all_by_name('Default Setup')
    AuthConfig.destroy auth_config
  end
end
