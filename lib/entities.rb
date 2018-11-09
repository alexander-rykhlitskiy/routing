module Entities
  CITY = Struct.new(:id, :x, :y, :deliveries) do
    def calculate_destination_to(other)
      Math.sqrt((x - other.x)**2 + (y - other.y)**2)
    end
  end

  BASE_CITY_ID = 0
  BASE_CITY = CITY.new(BASE_CITY_ID, 0, 0, [])

  DAY_DESCRIPTION = Struct.new(:n, :w, :k, :cities) do
    def index_cities_by_id
      @indexed_cities ||= [BASE_CITY, *cities].index_by(&:id)
    end
  end
end
