# a note on general run workflow:
# Runs are created as part of the trip scheduling 
# process; they're associated with a vehicle and
# a driver.  At the end of the day, the driver
# must update the run with post-run data like
# odometer start/end and no-shows.  That is 
# presented by my_runs and end_of_day

class RunsController < ApplicationController
  load_and_authorize_resource
  before_filter :filter_runs

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trips }
      format.js {
        rows = @runs.present? ? @runs.map do |r|
          render_to_string :partial => "row.html", :locals => { :run => r }
        end : [render_to_string( :partial => "no_runs.html" )]

        render :json => { :rows => rows }
      }
    end
  end

  def new
    @run = Run.new
    @run.provider_id = current_provider_id
    @drivers = Driver.where(:provider_id=>@run.provider_id)
    @vehicles = Vehicle.active.where(:provider_id=>@run.provider_id)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  def uncompleted_runs
    @runs = Run.where("complete = false").order("date desc")
    render "index"
  end

  def edit
    @drivers = Driver.where(:provider_id=>@run.provider_id)
    @vehicles = Vehicle.active.where(:provider_id=>@run.provider_id)
  end

  def create
    run_params = params[:run]
    authorize! :manage, current_provider
    run_params[:provider_id] = current_provider_id

    @run = Run.new(run_params)

    respond_to do |format|
      if @run.save
        format.html { redirect_to(@run, :notice => 'Run was successfully created.') }
        format.xml  { render :xml => @run, :status => :created, :location => @run }
      else
        @drivers = Driver.where(:provider_id=>@run.provider_id)
        @vehicles = Vehicle.active.where(:provider_id=>@run.provider_id)

        format.html { render :action => "new" }
        format.xml  { render :xml => @run.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    run_params = params[:run]
    authorize! :manage, current_provider
    run_params[:provider_id] = current_provider_id

    respond_to do |format|
      if @run.update_attributes(run_params)
        format.html { redirect_to(@run, :notice => 'Run was successfully updated.') }
        format.xml  { head :ok }
      else
        @drivers = Driver.where(:provider_id=>@run.provider_id)
        @vehicles = Vehicle.active.where(:provider_id=>@run.provider_id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @run.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @run = Run.find(params[:id])
    @run.destroy

    respond_to do |format|
      format.html { redirect_to(runs_url) }
      format.xml  { head :ok }
    end
  end
  
  def filter_runs
    if params[:end].present? && params[:start].present?
      @week_start = Time.at params[:start].to_i/1000
      @week_end   = Time.at params[:end].to_i/1000
    else
      time     = Time.now
      @week_start = time.beginning_of_week
      @week_end   = @week_start + 7.days
    end
    
    Rails.logger.debug("WEEK START: #{@week_start}")
    Rails.logger.debug("WEEK END: #{@week_end}")
    
    @runs = @runs.
      where("scheduled_start_time >= '#{@week_start.strftime "%Y-%m-%d %H:%M:%S"}'").
      where("scheduled_start_time <= '#{@week_end.strftime "%Y-%m-%d %H:%M:%S"}'")
  end
end
