class HomeController < ApplicationController
  def index
    @trip = Trip.new
    @trip.stops.build(position: 1)
    @trip.stops.build(position: 2)
  end
end
