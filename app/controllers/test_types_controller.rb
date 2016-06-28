class TestTypesController < ApplicationController
  
  def index
    @test_types = TestType.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @test_types }
    end
  end

  def show
    @test_type = TestType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @test_type }
    end
  end

  def new
    @test_type = TestType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @test_type }
    end
  end

  def edit
    @test_type = TestType.find(params[:id])
  end

  def create
    @test_type = TestType.new(params[:test_type])

    respond_to do |format|
      if @test_type.save
        flash[:notice] = "TestType was successfully created."
        format.html { redirect_to(@test_type) }
        format.xml  { render xml: @test_type, status: :created, location: @test_type }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @test_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @test_type = TestType.find(params[:id])

    respond_to do |format|
      if @test_type.update_attributes(params[:test_type])
        flash[:notice] = "TestType was successfully updated."
        format.html { redirect_to(@test_type) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @test_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @test_type = TestType.find(params[:id])
    @test_type.destroy

    respond_to do |format|
      format.html { redirect_to(test_types_url) }
      format.xml  { head :ok }
    end
  end
  
end