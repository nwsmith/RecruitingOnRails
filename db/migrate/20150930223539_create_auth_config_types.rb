class CreateAuthConfigTypes < ActiveRecord::Migration[7.0]
  def up
    create_table :auth_config_types do |t|
      t.string :code
      t.string :name
      t.string :description
    end

    AuthConfigType.create({:code => "INTERNAL", :name => "Internal", :description => "Internal authorization"})
    AuthConfigType.create({:code => "AD", :name => "Active Directory", :description => "Active Directory (LDAP)"})
  end

  def down
    drop_table :auth_config_types
  end
end
