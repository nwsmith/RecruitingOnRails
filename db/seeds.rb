# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
Registry.create([{key: 'dashboard.default_status', value: 'PEND'}])

auth_config_type = AuthConfigType.create({:code => 'RORI', :name => 'Internal', :description => 'Internal authorization'})
auth_config = AuthConfig.create({:auth_config_type => auth_config_type, :name => 'Default Setup'})

User.create({:first_name => 'Recruiting',
             :last_name => 'Admin',
             :user_name => 'admin',
             :password => 'q1w2e3r4',
             :auth_name => 'admin',
             :admin => true,
             :active => true,
             :auth_config => auth_config})
