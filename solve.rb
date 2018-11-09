require 'active_support/all'
require 'pry'
require 'redis'

DAY_DESCRIPTION = Struct.new(:n, :w, :k, :cities) do
  def sorted_cities
    @sorted_cities ||= cities.select(&:present?)
  end

  def index_cities_by_id
    @indexed_cities ||= [BASE_LOCATION, *cities].index_by(&:id)
  end
end

CITY_LOCATION = Struct.new(:id, :x, :y, :deliveries) do
  def destination_to(other)
    Math.sqrt((x - other.x)**2 + (y - other.y)**2)
  end

  def present?
    !deliveries.empty?
  end
end

BASE_LOCATION = CITY_LOCATION.new(0, 0, 0, [])

DELIVERY = Struct.new(:id, :weight, :city_id)

class Parser
  attr_reader :lines


  def initialize
    _, *@lines = File.readlines('input.txt')
  end

  def call
    arr = []

    until lines.empty?
      d = DAY_DESCRIPTION.new(*shift_line(lines), [])

      d.cities = d.n.times.map { |i| CITY_LOCATION.new(i + 1, *shift_line(lines), []) }

      m = d.cities.index_by(&:id)

      d.k.times do |i|
        delivery = DELIVERY.new(i + 1, *shift_line(lines))

        m[delivery.city_id].deliveries << delivery
      end

      arr << d
    end

    arr
  end

  def shift_line(lines)
    lines.shift.strip.split.map(&:to_i)
  end
end

class Solution
  attr_reader :days_info, :reporter

  def initialize(days_info, reporter: STDOUT)
    @days_info = days_info
    @reporter = reporter
  end

  def quick_sort(cities)
    send('m' + $method.to_s)
  end

  def m1(cities)
    result = cities.group_by do |city|
      if city.x >= 0 && city.y >= 0
        0
      elsif city.x >= 0 && city.y < 0
        1
      elsif city.x < 0 && city.y < 0
        2
      else
        3
      end
    end.values

    result.each_with_index.map do |cities, i|
      multiplier = i % 2 == 0 ? -1 : 1

      cities.sort_by { |city| BASE_LOCATION.destination_to(city) * multiplier }
    end.flatten
  end

  def m2(cities)
    result = cities.group_by do |city|
      if city.x >= 0
        0
      else
        3
      end
    end.values

    result.each_with_index.map do |cities, i|
      multiplier = i % 2 == 0 ? -1 : 1

      cities.sort_by { |city| BASE_LOCATION.destination_to(city) * multiplier }
    end.flatten
  end

  def m3(cities)
    result = cities.group_by do |city|
      if city.y >= 0
        0
      else
        3
      end
    end.values

    result.each_with_index.map do |cities, i|
      multiplier = i % 2 == 0 ? -1 : 1

      cities.sort_by { |city| BASE_LOCATION.destination_to(city) * multiplier }
    end.flatten
  end

  def m4(cities)
    result = cities.group_by do |city|
      if city.x >= 0 && city.y >= 0
        0
      elsif city.x >= 0 && city.y < 0
        1
      elsif city.x < 0 && city.y < 0
        2
      else
        3
      end
    end.values.sort_by { |city| BASE_LOCATION.destination_to(city) * multiplier }.flatten
  end


  def call
    result = 0

    days_info.each_with_index do |day, i|
      min_distance = 999999
      best_method = 999

      (1..4).each do |index|
        $method = index
        sorted_by_destination = quick_sort(day.cities)

        deliveries = day.cities.flat_map(&:deliveries).reverse

        sorted_deliveries = sorted_by_destination.flat_map do |city|
          deliveries.select { |delivery| delivery.city_id == city.id }
        end
        deliveries_count = 0

        distance = 0
        all_deliveries = sorted_deliveries

        flight = []
        flight_count = 0
        daily_flights = []

        until all_deliveries.empty?
          w = all_deliveries.pop

          if (flight + [w]).sum(&:weight) < day.w
            flight << w
          else
            deliveries_count += flight.size

            daily_flights.push "#{flight.size} #{flight.group_by(&:city_id).values.flatten.map(&:id).join(' ')}"

            flight_count += 1
            distance += make_flight(day, flight)

            flight = [w]
          end
        end

        unless flight.empty?
          flight_count += 1
          deliveries_count += flight.size
          daily_flights.push "#{flight.size} #{flight.group_by(&:city_id).values.flatten.map(&:id).join(' ')}"

          distance += make_flight(day, flight)
        end

        if distance < min_distance
          min_distance = distance
          best_method = index
          fc_df = [flight_count, daily_flights]
        end
      end

      result += distance

      flight_count, daily_flights = fc_df

      reporter.puts distance
      reporter.puts flight_count
      reporter.puts daily_flights
    end
  end

  def make_flight(day, active_deliveries)
    [0, *active_deliveries.map(&:city_id).uniq, 0].each_cons(2).sum do |lhs_id, rhs_id|
      day.index_cities_by_id[lhs_id].destination_to(day.index_cities_by_id[rhs_id])
    end
  end
end

f = File.open('best_solution_ever.txt', 'w')

Solution.new(Parser.new.call, reporter: f).call
