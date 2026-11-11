class TripsController < ApplicationController
  def show
    @trip = Trip.find(params[:id])
  end

  def create
    @trip = Trip.new(trip_params)

    if @trip.save
      redirect_to @trip, notice: "Trip created!"
    else
      render "home/index", status: :unprocessable_entity
    end
  end

  private

  def trip_params
    params.require(:trip).permit(:name, :start_date, :end_date, stops_attributes: [ :location ])
  end
end
