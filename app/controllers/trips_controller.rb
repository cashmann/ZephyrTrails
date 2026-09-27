class TripsController < ApplicationController
  def create
    @trip = Trip.new(trip_params)

    if @trip.save
      redirect_to root_path, notice: "Trip created!"
    else
      render "home/index", status: :unprocessable_entity
    end
  end

  private

  def trip_params
    params.require(:trip).permit(:name, :starting_location, :start_date, :end_date)
  end
end
