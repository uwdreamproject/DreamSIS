class FinancialAidSourcesController < FinancialAidPackagesController
  before_filter :fetch_financial_aid_package
  
  # GET /financial_aid_sources
  # GET /financial_aid_sources.json
  def index
    @financial_aid_sources = @financial_aid_package.sources

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @financial_aid_sources }
    end
  end

  # POST /financial_aid_sources
  # POST /financial_aid_sources.json
  def create
    @financial_aid_source = @financial_aid_package.sources.new(params[:financial_aid_source])

    respond_to do |format|
      if @financial_aid_source.save
        format.html { redirect_to [@participant, @financial_aid_package], notice: 'Financial aid source was successfully created.' }
        format.json { render json: {
            content: render_to_string(partial: 'source', object: @financial_aid_source, formats: [:html]),
            object: @financial_aid_source,
            breakdown: @financial_aid_source.breakdown(no_cents: true)
          }, status: :created, location: [@participant, @financial_aid_package] }
      else
        format.html { render action: "new" }
        format.json { render json: @financial_aid_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # *** Currently we don't support updated this record - just delete and recreate. ***
  # 
  # PUT /financial_aid_sources/1
  # PUT /financial_aid_sources/1.json
  # def update
  #   @financial_aid_source = @financial_aid_package.sources.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @financial_aid_source.update_attributes(params[:financial_aid_source])
  #       format.html { redirect_to [@participant, @financial_aid_package], notice: 'Financial aid source was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: "edit" }
  #       format.json { render json: @financial_aid_source.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /financial_aid_sources/1
  # DELETE /financial_aid_sources/1.json
  def destroy
    @financial_aid_source = @financial_aid_package.sources.find(params[:id])
    @financial_aid_source.destroy
    
    respond_to do |format|
      # format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
  
  protected
  
  def fetch_financial_aid_package
    @financial_aid_package = @participant.financial_aid_packages.find(params[:financial_aid_package_id])
  end
  
end
