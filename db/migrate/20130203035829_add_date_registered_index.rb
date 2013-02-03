class AddDateRegisteredIndex < ActiveRecord::Migration
  def up
    add_index :members, :date_registered
  end

  def down
  end
end
