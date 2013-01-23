class IndexController < ApplicationController
  def show
    @member = Member.where(:username => params[:username]).first
    if not @member
      @member = Member.create(:username => params[:username])
      @member.update_karma
    end    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @member }
    end
  end
end
