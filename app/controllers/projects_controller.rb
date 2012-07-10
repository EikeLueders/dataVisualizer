require 'resque'

class ProjectsController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.projects.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = current_user.projects.find(params[:id])

    puts '####################################################'
    puts Resque.size('insert_data_from_csv')
    puts '####################################################'
    
    @data = []
    @project.measured_data.each do |datum|
      datetime = datum.date.to_time.to_i * 1000
      @data << [datetime, datum.value.to_f]
    end

    @data = @data.to_json

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = current_user.projects.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = current_user.projects.find(params[:id])
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.projects.new(params[:project])

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = current_user.projects.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = current_user.projects.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end
  
  def newfileupload
    @project = current_user.projects.find(params[:project_id])
  end
  
  def fileupload
    @project = current_user.projects.find(params[:project_id])
    
    file = params[:datafile].tempfile
    
    Resque.enqueue(InsertDataFromCSV, @project.id, file)
    
    #@project.transaction do
    #  factor = @project.factor.to_f
    #  lastrowvalue = 0.0
    #  rowidx = 0
    #  CSV.parse(params[:datafile].tempfile, {headers: true, header_converters: :symbol, col_sep: ';'}).each do |row|
    #    datetime = DateTime.strptime(row[0] << 'T' << row[1], '%d.%m.%YT%H:%M:%S')
#
#        value_with_factor = row[2].to_f * factor
#        @project.measured_data.new(:date => datetime, :value => (rowidx == 0) ? 0 : value_with_factor - lastrowvalue, :aggregated_value => value_with_factor ).save!
#      
#        lastrowvalue = value_with_factor
#        rowidx += 1
#      end
#    end
    
    respond_to do |format|
      format.html {redirect_to @project, notice: 'File upload success.'}
    end
  end
end
