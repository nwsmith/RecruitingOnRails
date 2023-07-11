class CreateAuthConfigs < ActiveRecord::Migration[7.0]
  def up
    create_table :auth_configs do |t|
      t.references :auth_config_type

      t.string :name
      t.string :server
      t.integer :port
      t.string :ldap_base
      t.string :ldap_domain

      t.timestamps
    end

    change_table :users do |t|
      t.references :auth_config
    end

    execute <<-SQL
      ALTER TABLE auth_configs
        ADD CONSTRAINT fk_config_type
        FOREIGN KEY (auth_config_type_id)
        REFERENCES auth_config_types(id)
    SQL

    execute <<-SQL
      ALTER TABLE users
        ADD CONSTRAINT fk_auth_config
        FOREIGN KEY (auth_config_id)
        REFERENCES auth_configs(id)
    SQL
  end


  def down
    execute <<-SQL
      ALTER TABLE users
        DROP FOREIGN KEY fk_auth_config
    SQL

    remove_column :users, :auth_config_id

    execute <<-SQL
      ALTER TABLE auth_configs
        DROP FOREIGN KEY fk_config_type
    SQL

    drop_table :auth_configs
  end
end
