require 'open-uri'
require 'json'
require 'date'

class Member < ActiveRecord::Base
  attr_accessible :karma, :username, :date_registered

  def self.crawl_and_make_users
    url = "http://api.thriftdb.com/api.hnsearch.com/items/_search?sortby=create_ts%20desc&limit=100"
    doc = open(url).read
    j = JSON.parse(doc)
    new_members = 0
    updated_karma = 0
    j['results'].each do |item|
      username = item['item']['username']
      member = self.where(:username => username).first
      if not member
        sleep 1.0 # to be nice to the API provider
        self.make_from_api(username)
        new_members += 1
      else
        sleep 0.5
        updated_karma += member.update_karma
      end
    end
    "Saw #{new_members} new users, updated #{updated_karma} users' karma"
  end

  def self.make_from_api(username)
    url = "http://api.thriftdb.com/api.hnsearch.com/users/" + username
    doc = open(url).read
    j = JSON.parse(doc)
    self.create(
      :username => username,
      :karma => j['karma'],
      :date_registered => DateTime.strptime(j['create_ts'])
    )
  end
    
  def update_karma(force=false)
    if updated_at < DateTime.now - 6.hours or force
      url = "http://api.thriftdb.com/api.hnsearch.com/users/" + username
      doc = open(url).read
      j = JSON.parse(doc)
      karma = j['karma']
      save
      touch
      1
    else
      0
    end
  end
  
  def percentile(date=nil)
    if date
      start_date = date_registered.beginning_of_month
      end_date = date_registered.end_of_month
      total_users = Member.where(:date_registered => start_date..end_date)
    else
      total_users = Member
    end
    
    population = total_users.count
    below_karma = total_users.where("karma < ?", karma).count
    {"percentile" => (below_karma+1) / population.to_f, # +1 includes the user himself
     "below_karma" => below_karma,
     "population" => population}
  end
  
  def get_width(max_karma)
    if karma < 0
      0
    else
      karma / max_karma.to_f * 100
    end
  end
  
end
