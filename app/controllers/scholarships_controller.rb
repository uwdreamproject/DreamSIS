class ScholarshipsController < ResourceController
  self.object_class = Scholarship

  skip_before_filter :check_authorization, :only => [:show]
  protect_from_forgery :except => [:auto_complete_for_scholarship_title] 
  
  def index
    return redirect_to Scholarship.find(params[:id]) if params[:id]
    @scholarships = Scholarship.paginate :all, :page => params[:page]
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scholarships }
    end
  end
  
  def auto_complete_for_scholarship_title
    @scholarships = Scholarship.find(:all, :conditions => ["LOWER(title) LIKE ?", "%#{params[:scholarship][:title].to_s.downcase}%"], :limit => 20)
    render :partial => "shared/auto_complete_scholarship_title", 
            :object => @scholarships, 
            :locals => { :highlight_phrase => params[:scholarship][:title] }
  end
  
end