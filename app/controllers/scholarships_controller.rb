class ScholarshipsController < ResourceController
  self.object_class = Scholarship


  skip_before_filter :check_authorization, :only => [:show]
  protect_from_forgery :except => [:auto_complete_for_scholarship_title] 
  
  def index
    return redirect_to Scholarship.find(params[:id]) if params[:id]
		per_page = request.format.xls? ? 1000000 : params[:per_page]
    @scholarships = Scholarship.paginate :all, :page => params[:page], :per_page => per_page
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @scholarships }
			format.xls { render :layout => 'basic' }
    end
  end
  
	def merge
		@source = Scholarship.find(params[:source_id])
		@source_applications_count = @source.scholarship_applications.count
		@target = Scholarship.find(params[:target_id])
		@before_applications_count = @target.scholarship_applications.count
		
		if @source.merge_into(@target)
			@after_applications_count = @target.scholarship_applications.count
			flash[:notice] = "#{@source.title} was successfully merged into #{@target.title}. There were #{ActionController::Base.helpers.pluralize(@source_applications_count, 'application')} and #{@after_applications_count - @before_applications_count} of them were reassigned."
		else
			flash[:error] = "There was an error merging these two scholarship records."
		end
		redirect_back_or_default(:back)
	end
	
  def applications
    @scholarship = Scholarship.find(params[:id])

    respond_to do |format|
      format.html
      format.xls { render :layout => 'basic' }
    end    
  end

  def auto_complete_for_scholarship_title
    @scholarships = Scholarship.find(:all, :conditions => ["LOWER(title) LIKE ?", "%#{params[:scholarship][:title].to_s.downcase}%"], :limit => 20)
    render :partial => "shared/auto_complete_scholarship_title", 
            :object => @scholarships, 
            :locals => { :highlight_phrase => params[:scholarship][:title] }
  end
  
end