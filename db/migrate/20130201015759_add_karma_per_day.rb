class AddKarmaPerDay < ActiveRecord::Migration
  def up
    add_column :members, :karma_per_day, :float
    Member.all.each do |member|
       day_range = (Date.today - member.date_registered).to_f
       if day_range > 1
         member.karma_per_day = member.karma / day_range
       else
         member.karma_per_day = 0
       end
       member.save
    end
  end

  def down
    remove_column :members, :karma_per_day, :float
  end
end
