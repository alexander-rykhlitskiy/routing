module Entities
  CITY = Struct.new(:id, :x, :y, :deliveries) do
    def calculate_destination_to(other)
      Math.sqrt((x - other.x)**2 + (y - other.y)**2)
    end

    def ==(other)
      id == other.id
    end

    def weight_of_deliveries
      deliveries.sum(&:weight)
    end
  end

  BASE_CITY_ID = 0
  BASE_CITY = CITY.new(BASE_CITY_ID, 0, 0, [])

  DAY_DESCRIPTION = Struct.new(:n, :w, :k, :cities) do
    def index_cities_by_id
      @indexed_cities ||= [BASE_CITY, *cities].index_by(&:id)
    end
  end

  DELIVERY = Struct.new(:id, :weight, :city_id)

  class Route
    def full_distance

    end

    def to_s
      [deliveries.count, *deliveries.map(&:id)].join(' ')
    end
  end

  class DayFlightReport
    def initialize(routes)
      @routes = routes
    end

    def to_s
      [
        @routes.sum(&:full_distance),
        @routes.count,
        @routes.map(&:to_s).join("\n")
      ].join("\n")
    end
  end
end
