class GetDateRegData < ActiveRecord::Migration
  def up
    Member.where(:date_registered => nil).each do |member|
      url = "http://hnsearch.algolia.com/api/v1/users/" + member.username
      doc = open(url).read
      j = JSON.parse(doc)
      member.date_registered =j['created_at'].to_date
      member.save
      sleep 1.0
    end
    nil
  end

  def down
  end
end
