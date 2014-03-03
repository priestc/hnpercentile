require 'open-uri'
require 'json'
require 'date'

class Member < ActiveRecord::Base
  attr_accessible :karma, :username, :date_registered, :karma_per_day

  def self.users_for_month(month, year)
    start_date = Date.parse("#{year}-#{month}-1")
    end_date = start_date.end_of_month
    Member.where(:date_registered => start_date..end_date).order("karma DESC")
  end
  
  def self.crawl_and_make_users
 
    p "DEBUG: crawl_and_make_users"

    url = "http://hnsearch.algolia.com/api/v1/search_by_date"
    doc = open(url).read
    j = JSON.parse(doc)
    new_members = 0
    updated_karma = 0
    j['hits'].each do |item|
      username = item['author']
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
    p "DEBUG: make_from_api"

    url = "http://hnsearch.algolia.com/api/v1/users/" + username
    doc = open(url).read
    j = JSON.parse(doc)
    
    puts "DEBUG - "
    puts j['created_at']
    date_registered = DateTime.strptime(j['created_at'])
    karma = j['karma']
    date_range = (Date.today - date_registered).to_f
    
    if date_range > 1
      kpd = karma / date_range
    else
      kpd = karma
    end
    
    self.create(
      :username => username,
      :karma => karma,
      :karma_per_day => kpd,
      :date_registered => date_registered
    )
  end
    
  def update_karma(force=false)
    p "DEBUG update_karma"

    if updated_at < DateTime.now - 6.hours or force
      url = "http://hnsearch.algolia.com/api/v1/users/" + username
      doc = open(url).read
      j = JSON.parse(doc)
      self.karma = j['karma']
      day_range = (Date.today - date_registered).to_f
      if day_range > 1
        self.karma_per_day = self.karma / day_range
      else
        self.karma_per_day = self.karma
      end
      save
      touch
      1
    else
      0
    end
  end
  
  def percentile(date=false)
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
  
  def age
    (Date.today - date_registered).to_i
  end
  
  def per_day_percentile
    population = Member.count
    below_karma = Member.where("karma_per_day < ?", karma_per_day).count
    {"percentile" => (below_karma+1) / population.to_f, # +1 includes the user himself
     "below_karma_per_day" => below_karma,
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
