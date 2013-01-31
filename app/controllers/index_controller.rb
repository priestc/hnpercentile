class IndexController < ApplicationController
  def show
    @member = Member.where(:username => params[:username]).first
    if not @member
      @member = Member.make_from_api(params[:username])
    else
      @member.update_karma(:force => true)
    end
    attrs = @member.attributes
    attrs[:percentile] = @member.percentile
    attrs[:month_percentile] = @member.percentile(:date=>true)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: attrs }
    end
  end
  
  def month
    @month = params['month']
    @year = params['year']
    start_date = Date.parse("#@year-#@month-1")
    end_date = start_date.end_of_month
    @members = Member.where(:date_registered => start_date..end_date).order("karma DESC")
    @max_karma = @members.first.karma
    @percent_of_total_by_users = @members.count / Member.count.to_f * 100
    @percent_of_total_by_karma = @members.sum(:karma) / Member.sum(:karma).to_f * 100
    
    @next_month_obj = (end_date + 15.days).beginning_of_month
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
    @members = Member.order("karma DESC").limit(100)
    @max_karma = @members.first.karma
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @members }
    end
  end
end
