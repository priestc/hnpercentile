class AddSomeConstraints < ActiveRecord::Migration
  def up
    add_index :members, :username, :unique => true
  end

  def down
  end
end
