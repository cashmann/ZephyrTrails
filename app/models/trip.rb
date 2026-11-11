class Trip < ApplicationRecord
  MAX_STOPS = 20

  has_many :stops, -> { order(:position) }, dependent: :destroy, inverse_of: :trip
  accepts_nested_attributes_for :stops, allow_destroy: true

  before_validation :limit_stops, :number_stops

  validates :name, presence: true
  validate :has_start_and_end
  validate :find_routes

  def ordered_stops
    stops.sort_by.with_index { |stop, index| [ stop.position || Float::INFINITY, index ] }
  end

  def itinerary
    ordered_stops.reject(&:marked_for_destruction?)
  end

  def starting_stop
    itinerary.first
  end

  def ending_stop
    itinerary.last
  end

  def route_distance
    itinerary.drop(1).sum(&:route_distance)
  end

  def route_duration
    itinerary.drop(1).sum(&:route_duration)
  end

  private

  def limit_stops
    return if itinerary.size <= MAX_STOPS

    errors.add(:base, "A trip can have at most #{MAX_STOPS} stops")
    throw :abort
  end

  def number_stops
    itinerary.each.with_index(1) do |stop, position|
      stop.position = position
    end
  end

  def has_start_and_end
    errors.add(:base, "A trip needs a starting and an ending location") if itinerary.size < 2
  end

  def find_routes
    return if errors.any?

    itinerary.each_cons(2) do |from, to|
      next unless leg_outdated?(from, to)

      find_route(from, to)
      break if errors.any?
    end
  end

  def leg_outdated?(from, to)
    to.new_record? || from.moved? || to.moved?
  end

  def find_route(from, to)
    to.assign_route(OpenRouteService.driving_route(from.coordinates, to.coordinates))

  rescue OpenRouteService::Error => e
    add_route_error(e, from, to)
  end

  def add_route_error(error, from, to)
    case error
    when OpenRouteService::NoRouteError
      errors.add(:base, "There's no driving route from #{from.location} to #{to.location}")
    when OpenRouteService::RouteTooLongError
      errors.add(:base, "The drive from #{from.location} to #{to.location} is too long for driving directions (the limit is about 3,700 miles)")
    else
      Rails.logger.error(error.message)
      errors.add(:base, "Driving directions couldn't be looked up right now, please try again")
    end
  end
end
