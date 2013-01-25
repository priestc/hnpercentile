require 'open-uri'
require 'json'
require 'date'

class Member < ActiveRecord::Base
  attr_accessible :karma, :username, :date_registered

  def self.get_percentile(username)
    member = self.where(:username => username).first!
    member.update_karma
    member.percentile
  end

  def self.update_all_karma
    now = DateTime.now
    self.all.each do |member|
      if member.updated_at < now - 24.hours
        member.update_karma
        sleep 1.0 # to be nice to the API provider
      else
        ago = (Time.zone.now - member.updated_at) / 3600
        puts "skipping, last update #{ago} hours ago."
      end
    end
    nil
  end

  def self.crawl_and_make_users
    url = "http://api.thriftdb.com/api.hnsearch.com/items/_search?sortby=create_ts%20desc&limit=100"
    doc = open(url).read
    j = JSON.parse(doc)
    new_members = 0
    j['results'].each do |item|
      username = item['item']['username']
      member = self.where(:username => username).first
      if not member
        sleep 1.0 # to be nice to the API provider
        self.make_from_api(username)
        new_members += 1
      end
    end
    "Saw #{new_members} new users"
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
    
  def update_karma
    url = "http://api.thriftdb.com/api.hnsearch.com/users/" + username
    doc = open(url).read
    j = JSON.parse(doc)
    self.karma = j['karma']
    save
  end
  
  def percentile(date=nil)
    if date
      total_users = 2 #Member.where("date_registered "
      below_karma = 3
    else
      total_users = Member.count
      below_karma = Member.where("karma < ?", karma).count
    end
      below_karma / total_users.to_f
  end
  
end
