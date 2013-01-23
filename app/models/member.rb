require 'open-uri'
require 'json'

class Member < ActiveRecord::Base
  attr_accessible :karma, :username

  def self.get_percentile(username)
    member = self.where(:username => username).first!
    member.update_karma
    member.percentile
  end

  def self.update_all_karma
    self.all.each do |member|
      member.update_karma
      sleep 1.0 # to be nice to the API provider
    end
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
        member = self.create(:username => username, :karma => 0)
        new_members += 1
      end
    end
    "Saw #{new_members} new users"
  end

  def update_karma
    url = "http://api.thriftdb.com/api.hnsearch.com/users/" + username
    doc = open(url).read
    j = JSON.parse(doc)
    self.karma = j['karma']
    save
  end
  
  def percentile
    Member.where("karma < ?", karma).count / Member.count.to_f
  end
  
end