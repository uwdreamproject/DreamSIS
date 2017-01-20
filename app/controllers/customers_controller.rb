class CustomersController < ApplicationController
  before_filter :require_admin_tenant, except: [:show, :edit, :update]
  before_filter :restrict_to_current_tenant
  
  def index
    @customers = Customer.all
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @customers }
    end
  end
  
  def show
    @customer = Customer.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @customer }
    end
  end
  
  def new
    @customer = Customer.new
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @customer }
    end
  end
  
  def edit
    @customer = Customer.find(params[:id])
  end
  
  def create
    @customer = Customer.new(customer_params)
  
    respond_to do |format|
      if @customer.save
        flash[:notice] = 'Customer was successfully created.'
        format.html { redirect_to(@customer) }
        format.xml  { render xml: @customer, status: :created, location: @customer }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @customer.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @customer = Customer.find(params[:id])
  
    respond_to do |format|
      if @customer.update_attributes(customer_params)
        flash[:notice] = 'Customer was successfully updated.'
        format.html { redirect_to(@customer) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @customer.errors, status: :unprocessable_entity }
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
  
  private
  
  def customer_params
    params.require(:customer).permit(
      :name, :program_id, :parent_customer_id, :link_to_uw, :term_system, :risk_form_content, :require_background_checks, :mentor_label, :lead_label, :participant_label, :workbook_label, :intake_survey_label, :created_at, :updated_at, :mentee_label, :experimental, :clearinghouse_customer_number, :clearinghouse_contract_start_date, :clearinghouse_number_of_submissions_allowed, :url_shortcut, :allowable_login_methods, :visit_label, :college_application_choice_options, :paperwork_status_options, :not_target_label, :activity_log_student_time_categories, :activity_log_non_student_time_categories, :background_check_validity_length, :conduct_form_content, :driver_form_content, :send_driver_form_emails, :display_nicknames_by_default, :driver_training_validity_length, :clearinghouse_customer_name, :clearinghouse_entity_type, :stylesheet_url, :require_parental_consent_for_minors, :allow_participant_login,
      {
        allowable_login_methods: Customer::OMNIAUTH_PROVIDERS,
        visit_attendance_option_list: [],
        mentor_term_tag_list: []
      }
    )
  end
  
end
