class Trip < ApplicationRecord
  has_many :stops, -> { order(:position) }, dependent: :destroy, inverse_of: :trip
  accepts_nested_attributes_for :stops

  before_validation :number_stops

  validates :name, presence: true
  validate :has_start_and_end
  validate :find_routes

  def starting_stop
    stops.first
  end

  def ending_stop
    stops.last
  end

  def route_distance
    stops.drop(1).sum(&:route_distance)
  end

  def route_duration
    stops.drop(1).sum(&:route_duration)
  end

  private

  def number_stops
    stops.each.with_index(1) do |stop, position|
      stop.position = position
    end
  end

  def has_start_and_end
    errors.add(:base, "A trip needs a starting and an ending location") if stops.size < 2
  end

  def find_routes
    return if errors.any?

    stops.sort_by(&:position).each_cons(2) do |from, to|
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
