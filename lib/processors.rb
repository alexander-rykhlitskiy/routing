module Processors
  class Base
    attr_reader :day_info

    def initialize(day_info, **)
      @day_info = day_info
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

    def call
      @destinations.each_with_object({}) do |destination, hash|
        distance = source.calculate_destination_to(destination)
        weight = destination.weight_of_deliveries

        hash[:distance] = distance
        hash[:weight] = weight
        hash[:score] = weight.to_f / distance
      end
    end
  end
end
