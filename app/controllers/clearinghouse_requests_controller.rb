class ClearinghouseRequestsController < ApplicationController
  
  def index
    @clearinghouse_requests = ClearinghouseRequest.all
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @clearinghouse_requests }
    end
  end
  
  def show
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
    flash[:notice] = params[:message] if params[:message]
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @clearinghouse_request }
    end
  end
  
  def new
    @clearinghouse_request = ClearinghouseRequest.new(inquiry_type: "DA")
    @clearinghouse_request.customer_id = Customer.current_customer.id
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @clearinghouse_request }
    end
  end
  
  def edit
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
    redirect_to @clearinghouse_request
  end
  
  def file
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
    if params[:file] == 'submission'
      file_url = @clearinghouse_request.file_url(:submission)
    elsif !params[:file].blank?
      file_url = @clearinghouse_request.file_url(params[:file])
    end
    redirect_to file_url
  rescue KeyError => e
    flash[:error] = "The requested file is not included in the list of available files for this request."
    redirect_to :back
  end
  
  def refresh_status
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
    @output = @clearinghouse_request.log_contents
    
    respond_to do |format|
      format.js
    end
  end
  
  def submit
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
    if @clearinghouse_request.submit!
      flash[:notice] = "The file was successfully submitted to NSC for processing. You will receive an email when it has been processed."
    else
      flash[:error] = "There was a problem submitting the file. Please try again or submit the file to NSC manually."
    end
    redirect_to(@clearinghouse_request)
  end

  def retrieve
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
    if @clearinghouse_request.retrieve!
      flash[:notice] = "The file was successfully retrieved from NSC and accepted for processing."
    else
      flash[:error] = "There was a problem retrieving the file. Please try again or upload the results file manually."
    end
    redirect_to(@clearinghouse_request)
  end
  
  def close
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
    if @clearinghouse_request.close
      flash[:notice] = "The request was closed out."
    else
      flash[:error] = "There was a problem closing out the request."
    end
    redirect_to(@clearinghouse_request)
  end
  
  def results
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
  end
  
  def create
    @clearinghouse_request = ClearinghouseRequest.new(params[:clearinghouse_request])
    @clearinghouse_request.customer_id = Customer.current_customer.id
    @clearinghouse_request.selection_criteria = params[:cohorts].collect{|c| "Class of #{c}"}
    participants = Participant.where(grad_year: params[:cohorts])
    
    if ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:clearinghouse_request][:exclude_inactive])
      @clearinghouse_request.selection_criteria << "Exclude inactive"
      participants = participants.where(inactive: [false, nil])
    end
    
    if ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:clearinghouse_request][:exclude_not_target])
      @clearinghouse_request.selection_criteria << "Exclude #{Customer.not_target_label}"
      participants = participants.where(not_target_participant: [false, nil])
    end
    
    @clearinghouse_request.participants = participants
    
    respond_to do |format|
      if @clearinghouse_request.save
        flash[:notice] = 'Request was successfully created.'
        format.html { redirect_to(@clearinghouse_request) }
        format.xml  { render xml: @clearinghouse_request, status: :created, location: @clearinghouse_request }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @clearinghouse_request.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
  
    respond_to do |format|
      if @clearinghouse_request.update_attributes(params[:clearinghouse_request])
        flash[:notice] = 'Request was successfully updated.'
        format.html { redirect_to(@clearinghouse_request) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @clearinghouse_request.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def upload
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
    file_io = params[:retrieved_file]
    path = "tmp/nsc/#{@clearinghouse_request.id.to_s}/uploads/#{file_io.original_filename}"
    FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
    File.open(path, 'w') do |file|
      file.write(file_io.read)
    end
    
    if ClearinghouseRequestJob.perform_later(@clearinghouse_request.id, path)
      flash[:notice] = "Retrieved file accepted for processing."
    else
      flash[:error] = "The file could not be processed."
    end
    redirect_to @clearinghouse_request
  end
  
  def destroy
    @clearinghouse_request = ClearinghouseRequest.find(params[:id])
    @clearinghouse_request.destroy
  
    respond_to do |format|
      format.html { redirect_to(clearinghouse_requests_url) }
      format.xml  { head :ok }
    end
  end
  
end
