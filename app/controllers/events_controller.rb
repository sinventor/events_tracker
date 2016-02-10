class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy, :get_same]

  # GET /events
  # GET /events.json
  def index
    @events = current_user.events
    if params[:start] && params[:end]
      @events = @events.where("start >= :start AND end_date <= :end", start: params[:start], end: params[:end])
    end
    respond_with @events
  end

  # GET /events/1
  # GET /events/1.json
  def show
    respond_with(@event)
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params.merge(user: current_user))
    @event.end_date_of_series = params[:series_end] if params[:series_end]
    @event.save
    respond_with(@event)
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    @event.is_requested_apply_for_all_one_based = true if params[:update_same] && ['t', 'true'].include?(params[:update_same])
    @event.needed_recompute_end_date = true if params[:recompute] && ['t', 'true'].include?(params[:recompute])

    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Событие было успешно обновлено.' }
        format.json { render json: @event, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.is_requested_apply_for_all_one_based = true if params[:delete_same] && ['t', 'true'].include?(params[:delete_same])
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Событие удалено.' }
      format.json { head :no_content }
    end
  end

  def get_same
    @same_events = Event.with_same_base(@event)
    render json: @same_events
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:title, :start, :end_date, :is_repeated, :repeat_interval)
    end
end
