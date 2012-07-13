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
    
    #@data = []
    #@project.measured_data.each do |datum| # besser NICHT bei vielen Daten ;)
    #@project.approximated_measured_data.where('resolution = ?', 10).each do |datum|
    #@project.approximated_measured_data.where('resolution = ?', 180).each do |datum|
    #@project.approximated_measured_data.where('resolution = ?', 1440).each do |datum|
    #  datetime = datum.date.to_time.to_i * 1000
    #  @data << [datetime, datum.value.to_f]
    #end

    #@data = @data.to_json

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

    begin
      file = params[:datafile].tempfile
    rescue
      respond_to do |format|
        format.html { redirect_to project_newfileupload_path(@project), alert: 'You have to choose a file to upload a file.' }
        format.json { head :no_content }
      end
      return
    end
    
    # add resque job
    Resque.enqueue(InsertDataFromCSV, @project.id, file)
    
    respond_to do |format|
      format.html {redirect_to @project, notice: 'File upload success.'}
    end
  end

	def ajax_data_load
		@project = Project.find(params[:project_id])
		
    from_timestamp, to_timestamp = params[:from], params[:to]
		
		logger.debug "from - to"
		logger.debug from_timestamp
		logger.debug to_timestamp
		
		from_time, to_time = Time.at(from_timestamp.to_f/1000), Time.at(to_timestamp.to_f/1000)
		
		interval = to_time-from_time
		mins = interval/60
		
		# Verhaeltniswert berechnen
		#prop_value = calc_resolution(mins)
		
		# Aufloesung aus gegebenen Aufloesungen waehlen
		#best_resolution = get_best_resolution(prop_value, @project.resolutions)
		best_resolution = 10
		
		@data = []
    #@project.measured_data.each do |datum| # besser NICHT bei vielen Daten ;)
    #@project.approximated_measured_data.where('resolution = ?', 10).each do |datum|
    @project.approximated_measured_data.where('resolution = ?', best_resolution).each do |datum|
    #@project.approximated_measured_data.where('resolution = ?', 1440).each do |datum|
      datetime = datum.date.to_time.to_i * 1000
      @data << [datetime, datum.value.to_f]
    end

		respond_to do |format|
	    format.json { render json: @data }
    end		
	end
	
	protected
	
	def calc_resolution(mins)
	  mins / 100_000
	end
	
	def get_best_resolution(prop_val, resolutions)
	  # Aufloesung bestimmen
	end
end
