class HomeController < ApplicationController
  def index
    @trip = Trip.new
    @trip.stops.build
    @trip.stops.build
  end
end
