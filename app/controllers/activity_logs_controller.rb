class ActivityLogsController < ApplicationController
  skip_before_filter :check_authorization, :only => [:my_week, :my_current_week, :update]
	
  def index
    @activity_logs = ActivityLog.paginate :all, :page => params[:page]
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activity_logs }
    end
  end
  
  def show
    @activity_log = ActivityLog.find(params[:id])
  
    respond_to do |format|
      format.html { redirect_to edit_activity_log_path(@activity_log) }
      format.xml  { render :xml => @activity_log }
    end
  end
	
	def my_week
		@date = Date.strptime "#{params[:year]}-#{params[:month]}-#{params[:day]}"
		@activity_log = ActivityLog.find_or_create_by_mentor_and_week_and_year(@current_user.try(:person), @date.cweek, @date.year)
		render :action => 'edit'
	end
	
	def my_current_week
		@activity_log = ActivityLog.current_for(@current_user.try(:person))
		render :action => 'edit'
	end

	def weekly_summary
		@start_date = params[:year] ? Date.strptime("#{params[:year]}-#{params[:month]}-#{params[:day]}") : Date.today.beginning_of_week
		
		conditions_string = "start_date = :start_date AND end_date = :end_date"
		conditions_values = { :start_date => @start_date, :end_date => @start_date + 6.days }

		if params[:mentor_term_group_id] && params[:mentor_term_group_id] != "All"
			@mentor_term_group = MentorTermGroup.find params[:mentor_term_group_id]
			conditions_string << " AND mentor_id IN (:mentor_ids)"
			conditions_values[:mentor_ids] = @mentor_term_group.mentor_ids
		end

		@activity_logs = ActivityLog.find(:all, :conditions => [conditions_string, conditions_values])
		
		@direct_interaction_count = @activity_logs.collect(&:direct_interaction_count).numeric_items
		@indirect_interaction_count = @activity_logs.collect(&:indirect_interaction_count).numeric_items
		
		@time_breakdown = { "student_time" => {}, "non_student_time" => {}}
		@activity_logs.each do |al|
			for ctype in %w[student non_student]
				if al.instance_eval("#{ctype}_time?")
					al.instance_eval("#{ctype}_time").each do |category, value| 
						@time_breakdown["#{ctype}_time"][category] ||= 0
						@time_breakdown["#{ctype}_time"][category] += value.to_i
					end
				end
			end
		end
	end
  
  def new
    @activity_log = ActivityLog.new
    @activity_log.customer_id = Customer.current_customer.id
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity_log }
    end
  end
  
  def edit
    @activity_log = ActivityLog.find(params[:id])
  end
  
  def create
    @activity_log = ActivityLog.new(params[:activity_log])
    @activity_log.customer_id = Customer.current_customer.id
    
    respond_to do |format|
      if @activity_log.save
        flash[:notice] = 'Activity Log was successfully created.'
        format.html { redirect_to(@activity_log) }
        format.xml  { render :xml => @activity_log, :status => :created, :location => @activity_log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity_log.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @activity_log = ActivityLog.find(params[:id])      
		
    unless @current_user && (@current_user.admin? || @activity_log.belongs_to?(@current_user))
      return render_error("You are not allowed to update that activity log.")
    end

    respond_to do |format|
      if @activity_log.update_attributes(params[:activity_log])
				format.js		{ flash[:saved] = "Saved." }
        format.html { flash[:notice] = 'Activity Log was successfully updated.'; redirect_to(@activity_log) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity_log.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @activity_log = ActivityLog.find(params[:id])
    @activity_log.destroy
  
    respond_to do |format|
      format.html { redirect_to(activity_logs_url) }
      format.xml  { head :ok }
    end
  end
	

end