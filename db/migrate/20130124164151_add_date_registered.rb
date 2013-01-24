require 'json'
require 'open-uri'
require 'date'

class AddDateRegistered < ActiveRecord::Migration
  def up
    add_column :members, :date_registered, :date
  end

  def down
  end
end
