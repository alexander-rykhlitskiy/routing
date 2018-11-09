class DistanceCalculator
  class << self
    def closest_city(city, cities)
      (cities - [city]).min_by { |city_i| distance(city, city_i) }
    end

    private

    def distance(city1, city2)
      Math.sqrt((city1.x - city2.x).abs ** 2 + (city1.y - city2.y).abs ** 2)
    end
  end
end


cities = [City.new(1, 10, 10), City.new(2, 20, 20), City.new(3, -10, -10), City.new(4, 20, 30)]
raise('fail 1') unless DistanceCalculator.closest_city(cities[0], cities) == cities[1]

cities = [City.new(1, 10, 10), City.new(2, 20, 120), City.new(3, -10, -10), City.new(4, 20, 30)]
raise('fail 2') unless DistanceCalculator.closest_city(cities[0], cities) == cities[3]

cities = [City.new(1, 10, 10), City.new(2, 20, 120), City.new(3, -10, -10), City.new(4, 120, 30)]
raise('fail 3') unless DistanceCalculator.closest_city(cities[0], cities) == cities[2]

puts 'DistanceCalculator specs success'
