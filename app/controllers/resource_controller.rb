class ResourceController < ApplicationController
  
  class << self
    attr_accessor :object_class
    
    def object_name; object_class.to_s.underscore; end
    def objects_name; object_name.pluralize; end    
  end
  
  def index
    @objects = self.class.object_class.find(:all)
    load_variables
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @objects }
    end
  end
  
  def show
    @object = self.class.object_class.find(params[:id])
    load_variables
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @object }
    end
  end
  
  def new
    @object = self.class.object_class.new
    load_variables
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @object }
    end
  end
  
  def edit
    @object = self.class.object_class.find(params[:id])
    load_variables
  end
  
  def create
    @object = self.class.object_class.new(params[self.class.object_name])
    load_variables
      
    respond_to do |format|
      if @object.save
        flash[:notice] = "#{self.class.object_name.titleize} was successfully created."
        format.html { redirect_to(@object) }
        format.xml  { render xml: @object, status: :created, location: @object }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @object.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @object = self.class.object_class.find(params[:id])
    load_variables
  
    respond_to do |format|
      if @object.update_attributes(params[self.class.object_name])
        flash[:notice] = "#{self.class.object_name.titleize} was successfully updated."
        format.html { redirect_to(@object) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @object.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @object = self.class.object_class.find(params[:id])
    @object.destroy
    load_variables
  
    respond_to do |format|
      format.html { redirect_to(self.instance_eval("#{self.class.object_names}_path")) }
      format.xml  { head :ok }
    end
  end
  
  protected 
  
  def load_variables
    self.instance_eval("@#{self.class.objects_name} = @objects") if @objects
    self.instance_eval("@#{self.class.object_name} = @object") if @object
  end
  
  
end