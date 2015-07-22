class ChangesController < ApplicationController
  
  ALLOWABLE_MODELS = %w[Person User Participant Mentor Volunteer PubcookieUser CollegeApplication ScholarshipApplication]
  
  # GET /changes/for/:model_name/:id
  def for_object
    @object = validate_and_instantiate_object_from_params(params[:model_name], params[:id])
    ids = [[@object.class.to_s, @object.id]]
    ids += @object.child_objects.collect{|o| [o.class.to_s, o.id] } if @object.respond_to?(:child_objects)
    conditions_string = ids.size.times.collect{ "(change_loggable_type = ? AND change_loggable_id = ?)" }.join(" OR ")
    @changes = Change.where([conditions_string] + ids.flatten)

    render :action => "index"
  end
  
  def deleted
    @changes = Change.paginate(:all, 
      :conditions => ["change_loggable_type IN (?) AND action_type = ?", ALLOWABLE_MODELS, 'delete'], 
      :page => params[:page], 
      :per_page => 10)
    @allowable_models = ALLOWABLE_MODELS
  end
  
  def undelete
    @change = Change.find(params[:id])
    raise Exception.new("Already undeleted") if @change.restored?
    raise Exception.new("Can only undelete allowable models") unless ALLOWABLE_MODELS.include?(@change.change_loggable_type.to_s)
    new_object = @change.undelete!
    flash[:notice] = "The record was successfully restored."
    redirect_to(new_object) rescue redirect_to(:back)
  end
  
  protected
  
  def validate_and_instantiate_object_from_params(model_name, object_id)
    klass = model_name.to_s.camelcase.constantize
    raise ActionController::RoutingError.new("Invalid class name") if !ALLOWABLE_MODELS.include?(klass.to_s)
    klass.find(object_id)
  end
  
end