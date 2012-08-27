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

    file = nil

    # get file object
    begin
      file = params[:datafile].tempfile
    rescue
      # if no file was specified show error and get back to upload form
      respond_to do |format|
        format.html { redirect_to project_newfileupload_path(@project), alert: 'You have to choose a file to upload a file.' }
        format.json { head :no_content }
      end
      return
    end
  
    # add resque job
    Resque.enqueue(InsertDataFromCSV, @project.id, file)
    
    respond_to do |format|
      format.html {redirect_to @project, notice: "File upload success. Please wait a few seconds, while all data is processed..."}
    end
  end

  # Load data with ajax request
	def ajax_data_load
		@project = Project.find(params[:project_id])
		
		@data = []
		@data_aggregated = []
		
		# if any data is avaiable
		if not @project.measured_data.empty?
		  
		  # if timespan is given use it to extract data
  		if params.has_key?(:from) and params.has_key?(:to)
  		  from_timestamp, to_timestamp = params[:from], params[:to]
  		  from_time, to_time = Time.at(from_timestamp.to_f/1000), Time.at(to_timestamp.to_f/1000)
  		  
  		# otherwise get all avaiable data
      else 
        from_time = @project.measured_data.minimum(:date)
        to_time = @project.measured_data.maximum(:date)
      end
    
      plot_width = params[:plotwidth].to_i
		
  		interval = to_time - from_time
  		calc_resolution = (interval / 60) / (plot_width / 2)
		
  		# Aufloesung aus gegebenen Aufloesungen waehlen
  		best_resolution = get_best_resolution(calc_resolution, @project.resolutions.map { |r| r.value })
		
		  # time hartcodieren... funktioniert mit sql funktion nicht???
  		db_from = from_time.strftime("%Y-%m-%d %H:%M:%S")
      db_to = to_time.strftime("%Y-%m-%d %H:%M:%S")
    		
  		if best_resolution == 2
  		  cond = "date BETWEEN '#{db_from}' AND '#{db_to}'"
  		  query = @project.measured_data.all(:order => 'date ASC', :conditions => [cond])
  		else
  		  cond = "date BETWEEN '#{db_from}' AND '#{db_to}' AND resolution = #{best_resolution}"
  		  query = @project.approximated_measured_data.all(:order => 'date ASC', :conditions => [cond])
  		end
		
  		query.each do |datum|
        datetime = datum.date.to_time.to_i * 1000
        @data << [datetime, datum.value.to_f]
        @data_aggregated << [datetime, datum.aggregated_value.to_f]
      end
    end 
		respond_to do |format|
		  format.json { render json: [@data, @data_aggregated] }
		end
	end
	
	protected
	
	def get_best_resolution(prop_val, resolutions)
	  resolutions << 2
	  
	  abs_values = {}
	  resolutions.each do |r|
	    abs_values[(prop_val - r).abs] = r
    end
    
    min_key = abs_values.keys.min
    abs_values[min_key]
	end
end
