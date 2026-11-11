class Trip < ApplicationRecord
  validates :name, presence: true
  validates :starting_location, presence: true
  validates :ending_location, presence: true

  validate :geocode_locations
  validate :find_route

  private

  def geocode_locations
    %w[starting ending].each do |prefix|
      location = self["#{prefix}_location"]
      next if location.blank?
      next unless will_save_change_to_attribute?("#{prefix}_location")

      geocode_location(prefix, location)
    end
  end

  def geocode_location(prefix, location)
    result = Geocoder.search(location).first

    if result
      self["#{prefix}_latitude"], self["#{prefix}_longitude"] = result.coordinates
    else
      errors.add("#{prefix}_location", "couldn't be found. Check the spelling, or try a less specific address (e.g. just the city)")
    end
  rescue Geocoder::Error, Timeout::Error, SocketError, SystemCallError
    errors.add("#{prefix}_location", "couldn't be looked up right now, please try again")
  end

  def find_route
    return if errors.any?
    return unless route_outdated?

    assign_route(OpenRouteService.driving_route(starting_coordinates, ending_coordinates))

  rescue OpenRouteService::Error => e
    add_route_error(e)
  end

  def route_outdated?
    coordinate_attributes = %w[starting_latitude starting_longitude ending_latitude ending_longitude]
    new_record? || coordinate_attributes.any? { |attribute| will_save_change_to_attribute?(attribute) }
  end

  def starting_coordinates
    [ starting_latitude, starting_longitude ].map(&:to_f)
  end

  def ending_coordinates
    [ ending_latitude, ending_longitude ].map(&:to_f)
  end

  def assign_route(route)
    self.route_distance = route.distance
    self.route_duration = route.duration
    self.route_geometry = route.geometry
  end

  def add_route_error(error)
    case error
    when OpenRouteService::NoRouteError
      errors.add(:base, "There's no driving route between these locations")
    when OpenRouteService::RouteTooLongError
      errors.add(:base, "This trip is too long for driving directions (the limit is about 3,700 miles)")
    else
      Rails.logger.error(error.message)
      errors.add(:base, "Driving directions couldn't be looked up right now, please try again")
    end
  end
end
