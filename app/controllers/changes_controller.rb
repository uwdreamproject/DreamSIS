class ChangesController < ApplicationController
  
  ALLOWABLE_MODELS = %w[Person User Participant Mentor Volunteer PubcookieUser]
  
  # GET /changes/for/:model_name/:id
  def for_object
    @object = validate_and_instantiate_object_from_params(params[:model_name], params[:id])
    @changes = Change.find(:all, :conditions => { :change_loggable_type => @object.class.to_s, :change_loggable_id => @object.id })
    
    if @object.respond_to?(:child_objects)
      for child_object in @object.child_objects
        child_changes = Change.find(:all, :conditions => { :change_loggable_type => child_object.class.to_s, :change_loggable_id => child_object.id })
        @changes << child_changes unless child_changes.empty?
      end
      @changes.flatten!
    end
      
    render :action => "index"
  end
  
  protected
  
  def validate_and_instantiate_object_from_params(model_name, object_id)
    klass = model_name.to_s.camelcase.constantize
    raise ActionController::RoutingError.new("Invalid class name") if !ALLOWABLE_MODELS.include?(klass.to_s)
    klass.find(object_id)
  end
  
end