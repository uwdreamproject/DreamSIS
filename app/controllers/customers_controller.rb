class CustomersController < ApplicationController
  before_filter :require_admin_tenant, :except => [:show, :edit, :update]
  before_filter :restrict_to_current_tenant
  
  def index
    @customers = Customer.find :all
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
    end
  end
  
  def show
    @customer = Customer.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end
  
  def new
    @customer = Customer.new
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  end
  
  def edit
    @customer = Customer.find(params[:id])
  end
  
  def create
    @customer = Customer.new(params[:customer])
  
    respond_to do |format|
      if @customer.save
        flash[:notice] = 'Customer was successfully created.'
        format.html { redirect_to(@customer) }
        format.xml  { render :xml => @customer, :status => :created, :location => @customer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @customer = Customer.find(params[:id])
  
    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        flash[:notice] = 'Customer was successfully updated.'
        format.html { redirect_to(@customer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy
  
    respond_to do |format|
      format.html { redirect_to(customers_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def require_admin_tenant
    render_error("You are not allowed to access that page.") unless request.subdomain == 'admin'
  end
  
  def restrict_to_current_tenant
    return true if request.subdomain == 'admin'
    @customer = Customer.find(params[:id])
    render_error("You can only change the settings for your account.", "You are not allowed to access that page.") if @customer.tenant_name != Apartment::Tenant.current
  end
  
end
