class ProgramsController < ApplicationController
  skip_before_filter :check_authorization, only: [:index, :show]

  
  def index
    @programs = Program.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @programs }
    end
  end

  def show
    @program = Program.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @program }
    end
  end

  def new
    @program = Program.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @program }
    end
  end

  def edit
    @program = Program.find(params[:id])
  end

  def create
    @program = Program.new(params[:program])

    respond_to do |format|
      if @program.save
        flash[:notice] = "Program was successfully created."
        format.html { redirect_to(@program) }
        format.xml  { render xml: @program, status: :created, location: @program }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @program = Program.find(params[:id])

    respond_to do |format|
      if @program.update_attributes(params[:program])
        flash[:notice] = "Program was successfully updated."
        format.html { redirect_to(@program) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @program = Program.find(params[:id])
    @program.destroy

    respond_to do |format|
      format.html { redirect_to(programs_url) }
      format.js
    end
  end
  
end