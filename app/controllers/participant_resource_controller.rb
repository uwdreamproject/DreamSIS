class ParticipantResourceController < ParticipantsController
  before_filter :fetch_participant
  skip_before_filter :check_authorization

  class << self
    attr_accessor :object_class
    
    def object_name; object_class.to_s.underscore; end
    def objects_name; object_name.pluralize; end    
  end
  
  def index
    @objects = @participant.instance_eval("#{self.class.objects_name}.find(:all)")
    load_variables

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @objects }
    end
  end

  def show
    @object = @participant.instance_eval("#{self.class.objects_name}.find(#{params[:id]})")
    load_variables

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @object }
    end
  end

  def new
    @object = @participant.instance_eval("#{self.class.objects_name}.new")
    load_variables

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @object }
    end
  end

  def edit
    @object = @participant.instance_eval("#{self.class.objects_name}.find(#{params[:id]})")
    load_variables
  end

  def create
    instance_eval("@object = @participant.#{self.class.objects_name}.new(params[:#{self.class.object_name}])")
    load_variables

    respond_to do |format|
      if @object.save
        flash[:notice] = "#{self.class.object_name.titleize} was successfully created."
        format.html { redirect_to participant_path(@participant, :anchor => "!/section/#{self.class.objects_name}") }
        format.xml  { render :xml => @object, :status => :created, :location => @participant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @object.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @object = @participant.instance_eval("#{self.class.objects_name}.find(#{params[:id]})")
    load_variables
    respond_to do |format|
      if @object.update_attributes(params[self.class.object_name])
        flash[:notice] = "#{self.class.object_name.titleize} was successfully updated."
        format.html { redirect_to participant_path(@participant, :anchor => "!/section/#{self.class.objects_name}") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @object.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @object = @participant.instance_eval("#{self.class.objects_name}.find(#{params[:id]})")
    @object.destroy
    load_variables

    respond_to do |format|
      format.html { redirect_to participant_path(@participant, :anchor => "!/section/#{self.class.objects_name}") }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_participant
    @participant = Participant.find(params[:participant_id])
    
    unless @current_user && @current_user.can_view?(@participant)
      flash[:error] = "You are not allowed to edit this participant"
      return redirect_to :back
    end  
  end

  def load_variables
    self.instance_eval("@#{self.class.objects_name} = @objects") if @objects
    self.instance_eval("@#{self.class.object_name} = @object") if @object
  end
  
end
