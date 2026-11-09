class Trip < ApplicationRecord
  validates :name, presence: true
  validates :starting_location, presence: true
  validates :ending_location, presence: true

  validate :geocode_locations

  def geocoded?
    [ starting_latitude, starting_longitude, ending_latitude, ending_longitude ].all?(&:present?)
  end

  private

  def geocode_locations
    %w[starting ending].each do |prefix|
      location = self["#{prefix}_location"]
      next if location.blank?
      next unless will_save_change_to_attribute?("#{prefix}_location") || self["#{prefix}_latitude"].nil?

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
end
