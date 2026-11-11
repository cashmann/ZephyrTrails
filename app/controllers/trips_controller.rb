class TripsController < ApplicationController
  before_action :set_trip, only: [ :show, :edit, :update ]

  def index
    @trips = Trip.includes(:stops).order(created_at: :desc)
  end

  def show
  end

  def create
    @trip = Trip.new(trip_params)

    if @trip.save
      redirect_to @trip, notice: "Trip created!"
    else
      render "home/index", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: "Trip updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_trip
    @trip = Trip.find(params[:id])
  end

  def trip_params
    permitted = params.require(:trip).permit(:name, :start_date, :end_date, stops_attributes: [ :id, :location, :_destroy ])
    number_stops_in_form_order(permitted)

    permitted
  end

  def number_stops_in_form_order(permitted)
    permitted[:stops_attributes]&.each_value&.with_index(1) do |stop_attributes, position|
      stop_attributes[:position] = position
    end
  end
end
