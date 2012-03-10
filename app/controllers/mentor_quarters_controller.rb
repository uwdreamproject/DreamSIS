class MentorQuartersController < MentorQuarterGroupsController
  before_filter :fetch_mentor_quarter_group
  
  # def index
  #   @mentor_quarter = @mentor_quarter_group.mentor_quarters.find :all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @mentor_quarter }
  #   end
  # end

  def show
    @mentor_quarter = @mentor_quarter_group.mentor_quarters.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mentor_quarter }
    end
  end

  # def new
  #   @mentor_quarter = @mentor_quarter_group.mentor_quarters.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @mentor_quarter }
  #   end
  # end
  
  def edit
    @mentor_quarter = @mentor_quarter_group.mentor_quarters.find(params[:id])
  end

  def create
    new_mentor_user = PubcookieUser.authenticate params[:uw_netid]
    if new_mentor_user
      m = @mentor_quarter_group.mentor_quarters.create(:mentor_id => new_mentor_user.person.try(:id), :volunteer => true)
      if m.valid?
        flash[:notice] = "Successfully added #{new_mentor_user.fullname} to this group."
      else
        flash[:error] = "Could not add #{new_mentor_user.fullname} to this group, because #{m.errors.full_messages.to_sentence}."
      end
    else
      flash[:error] = "Could not find anyone with that UW NetID."
    end
    redirect_to mentor_quarter_group_path(@mentor_quarter_group, :newly_added => m.try(:id))
  end

  def update
    @mentor_quarter = @mentor_quarter_group.mentor_quarters.find(params[:id]) rescue nil
    @mentor_quarter = @mentor_quarter_group.deleted_mentor_quarters.find(params[:id]) unless @mentor_quarter

    respond_to do |format|
      if @mentor_quarter.update_attributes(params[:mentor_quarter])
        MentorQuarterGroup.increment_counter(:mentor_quarters_count, @mentor_quarter_group.id) if params[:increment_counter]
        flash[:notice] = "Successfully updated #{@mentor_quarter.fullname}."
        format.html { redirect_to(@mentor_quarter_group) }
        format.xml  { head :ok }
        format.js
      else
        flash[:error] = "Could not make changes to #{@mentor_quarter.fullname}'s record."
        format.html { redirect_to(@mentor_quarter_group) }
        format.xml  { render :xml => @mentor_quarter.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @mentor_quarter = @mentor_quarter_group.mentor_quarters.find(params[:id])
    @mentor_quarter.destroy

    flash[:notice] = "Successfully removed #{@mentor_quarter.fullname} from this group."
    respond_to do |format|
      format.html { redirect_to(@mentor_quarter_group) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_mentor_quarter_group
    @mentor_quarter_group = MentorQuarterGroup.find params[:mentor_quarter_group_id]
  end
  
end