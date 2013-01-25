class GetDateRegData < ActiveRecord::Migration
  def up
    Member.where(:date_registered => nil).each do |member|
      url = "http://api.thriftdb.com/api.hnsearch.com/users/" + member.username
      doc = open(url).read
      j = JSON.parse(doc)
      member.date_registered =j['create_ts'].to_date
      member.save
      sleep 1.0
    end
    nil
  end

  def down
  end
end
