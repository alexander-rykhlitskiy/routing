module Processors
  class Base
    attr_reader :day_info

    def initialize(day_info, **)
      @day_info = day_info
    end

    def call
      DayFlightReport.new(build_routes).to_s
    end

    def build_routes
      []
    end

    private

    def cities
      @cities ||= day_info.cities
    end

    def deliveries
      @deliveries ||= cities.flat_map(&:deliveries)
    end
  end

  class Stub < Base
    def call
      []
    end
  end

  class DistanceScoreCalculator
    def initialize(destinations)
      @destinations = destinations
    end

    def call(source, max_weight)
      @destinations.map do |destination|
        hash = {}
        distance = source.calculate_destination_to(destination)
        weight = 0
        deliveries = destination.deliveres.take_while { |d| weight += d.weight if max_weight >= weight + d.weight }

        hash[:destination] = destination
        hash[:distance] = distance
        hash[:weight] = weight
        hash[:score] = weight.to_f / distance
        hash[:deliveries] = deliveries
      end.max_by {|h| h[:score]}
    end
  end
end
