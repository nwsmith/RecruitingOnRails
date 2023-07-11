class AddAdminUser < ActiveRecord::Migration[7.0]
  def up
    auth_config = AuthConfig.find_all_by_name('Default Setup')

    User.create({:first_name => 'Recruiting',
                 :last_name => 'Admin',
                 :user_name => 'admin',
                 :password => 'q1w2e3r4',
                 :auth_name => 'admin',
                 :admin => true,
                 :active => true,
                 :auth_config => auth_config[0]})
  end

  def down
    User.destroy(User.find_all_by_auth_name('admin')[0])
  end
end
