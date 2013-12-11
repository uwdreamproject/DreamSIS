class MentorTermsController < MentorTermGroupsController
  before_filter :fetch_mentor_term_group
  
  # def index
  #   @mentor_term = @mentor_term_group.mentor_terms.find :all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @mentor_term }
  #   end
  # end

  def show
    @mentor_term = @mentor_term_group.mentor_terms.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mentor_term }
    end
  end

  # def new
  #   @mentor_term = @mentor_term_group.mentor_terms.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @mentor_term }
  #   end
  # end
  
  def edit
    @mentor_term = @mentor_term_group.mentor_terms.find(params[:id])
  end

  def create
    new_mentor_user = PubcookieUser.authenticate params[:uw_netid] if params[:uw_netid]
    @mentor = new_mentor_user.try(:person) || Mentor.find(params[:mentor_term][:mentor_id])
    if @mentor
      m = @mentor_term_group.enroll!(@mentor, :volunteer => true)
      if m.valid?
        flash[:notice] = "Successfully added #{@mentor.fullname} to this group."   
      else
        flash[:error] = "Could not add #{@mentor.fullname} to this group, because #{m.errors.full_messages.to_sentence}."
      end
    else
      flash[:error] = "Could not find anyone that user."
    end
    redirect_to mentor_term_group_path(@mentor_term_group, :newly_added => m.try(:id))
  end

  def update
    @mentor_term = @mentor_term_group.mentor_terms.find(params[:id]) rescue nil
    @mentor_term = @mentor_term_group.deleted_mentor_terms.find(params[:id]) unless @mentor_term

    respond_to do |format|
      if @mentor_term.update_attributes(params[:mentor_term])
        MentorTermGroup.increment_counter(:mentor_terms_count, @mentor_term_group.id) if params[:increment_counter]
        flash[:notice] = "Successfully updated #{@mentor_term.fullname}."
        format.html { redirect_to(@mentor_term_group) }
        format.xml  { head :ok }
        format.js
      else
        flash[:error] = "Could not make changes to #{@mentor_term.fullname}'s record."
        format.html { redirect_to(@mentor_term_group) }
        format.xml  { render :xml => @mentor_term.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @mentor_term = @mentor_term_group.mentor_terms.find(params[:id])
    @mentor_term.destroy

    flash[:notice] = "Successfully removed #{@mentor_term.fullname} from this group."
    respond_to do |format|
      format.html { redirect_to(@mentor_term_group) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_mentor_term_group
    @mentor_term_group = MentorTermGroup.find params[:mentor_term_group_id]
  end
  
end
