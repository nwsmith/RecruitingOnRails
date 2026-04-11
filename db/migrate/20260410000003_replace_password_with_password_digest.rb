class ReplacePasswordWithPasswordDigest < ActiveRecord::Migration[7.1]
  def up
    rename_column :users, :password, :password_digest
  end

  def down
    rename_column :users, :password_digest, :password
  end
end
