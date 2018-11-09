require_relative 'entities'

class Parser
  attr_reader :lines

  DELIVERY = Struct.new(:id, :weight, :city_id)

  def initialize(file_name)
    _, *@lines = File.readlines(file_name)
  end

  def call
    arr = []

    until lines.empty?
      d = DAY_DESCRIPTION.new(*shift_line(lines), [])

      d.cities = d.n.times.map { |i| CITY.new(i + 1, *shift_line(lines), []) }

      m = d.cities.index_by(&:id)

      d.k.times do |i|
        delivery = DELIVERY.new(i + 1, *shift_line(lines))

        m[delivery.city_id].deliveries << delivery
      end

      arr << d
    end

    arr
  end

  private

  def shift_line(lines)
    lines.shift.strip.split.map(&:to_i)
  end
end
