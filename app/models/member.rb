require 'open-uri'
require 'json'

class Member < ActiveRecord::Base
  attr_accessible :karma, :username

  def self.update_all_karma
    self.all.each do |member|
      member.update_karma
      member.save
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
        member.save
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
  end
end
