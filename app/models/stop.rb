class Stop < ApplicationRecord
  belongs_to :trip

  validates :position, presence: true
  validates :location, presence: true

  validate :geocode_location, if: -> { location.present? && will_save_change_to_location? }

  def coordinates
    [ latitude, longitude ].map(&:to_f)
  end

  def moved?
    will_save_change_to_latitude? ||
      will_save_change_to_longitude? ||
      will_save_change_to_position?
  end

  def assign_route(route)
    self.route_distance = route.distance
    self.route_duration = route.duration
    self.route_geometry = route.geometry
  end

  private

  def geocode_location
    result = Geocoder.search(location).first

    if result
      self.latitude, self.longitude = result.coordinates
    else
      errors.add(:location, "couldn't be found. Check the spelling, or try a less specific address (e.g. just the city)")
    end

  rescue Geocoder::Error, Timeout::Error, SocketError, SystemCallError
    errors.add(:location, "couldn't be looked up right now, please try again")
  end
end
