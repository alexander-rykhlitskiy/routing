module Processors
  class Base
    attr_reader :day_info

    def initialize(day_info, **)
      @day_info = day_info
    end

    def build_route(*parts)
      [BASE_CITY_ID, *parts, BASE_CITY_ID]
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
end
