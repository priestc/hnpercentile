class IndexController < ApplicationController
  def show
    uname = params[:username].strip
    member = Member.where(:username => uname).first
    if not member
      member = Member.make_from_api(uname)
    else
      member.update_karma(:force => true)
    end
    @attrs = member.attributes
    @attrs[:overall_data] = member.percentile
    @attrs[:month_data] = member.percentile(:date=>true)
    @attrs[:speed_data] = member.per_day_percentile
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @attrs }
    end
  end
  
  def month
    @month = params['month']
    @year = params['year']
    
    @members = Rails.cache.fetch("month-#@month-#@year", :expires_in => 10.minutes) do
      Member.users_for_month(@month, @year)
    end
    
    @max_karma = @members.first.karma
    @percent_of_total_by_users = @members.count / Member.count.to_f * 100
    @percent_of_total_by_karma = @members.sum(:karma) / Member.sum(:karma).to_f * 100
    
    start_date = Date.parse("#@year-#@month-1")
    
    @next_month_obj = (start_date + 35.days).beginning_of_month
    @next_month = @next_month_obj.strftime("%B %Y")
    @next_month_link = "/month/#@next_month".sub(' ', '-').downcase
    
    @prev_month_obj = (start_date - 15.days).beginning_of_month
    @prev_month = @prev_month_obj.strftime("%B %Y")
    @prev_month_link = "/month/#@prev_month".sub(' ', '-').downcase
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @members }
    end
  end
  
  def overall
    @members = Rails.cache.fetch("top_karma", :expires_in => 10.minutes) do 
      Member.order("karma DESC").limit(200)
    end
    @max_karma = @members.first.karma
    @max_age = 0
    @members.each do |member|
      if member.age > @max_age
        @max_age = member.age.to_f
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @members }
    end
  end
  
  def home
    @total_users = Member.count
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: {} }
    end
  end
  
  def superstars
    @members = Member.where('date_registered < ?', Date.today - 7.days).order("karma_per_day DESC").limit(200)
    @max_karma_per_day = @members.first.karma_per_day
    @max_age = 0
    @members.each do |member|
      if member.age > @max_age
        @max_age = member.age.to_f
      end
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @members }
    end
  end
  
  def all_months
    total_users = Member.count
    total_karma = Member.sum('karma')
    
    @month_names = Rails.cache.fetch('month_names', :expires_in => 20.hours) do
      Member.order('date_registered').map { |d| d.date_registered.strftime('%B %Y') }.uniq
    end
    
    @months = Rails.cache.fetch('month_data', :expires_in => 20.hours) do
      months = {}
      @month_names.each do |month_year|
        data = {}
        month, year = month_year.split(' ')
        users = Member.users_for_month(month, year)
        data[:users_percent] = users.count / total_users.to_f * 100
        data[:karma_percent] = users.sum('karma') / total_karma.to_f * 100
        data[:link] = month_year.downcase.sub(' ', '-')
        months[month_year] = data
      end
      months
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @months }
    end
  end
end
