require 'processors'
require 'city'
require 'distance_calculator'

class Solution
  attr_reader :days_info, :reporter, :day_processor, :options

  def initialize(days_info, reporter: STDOUT, day_processor: Processors::Base, **options)
    @days_info = days_info
    @reporter = reporter
    @day_processor = day_processor
    @options = options
  end

  def call
    days_info.map do |day_info|
      day_processor.new(day_info, **options).call
    end
  end
end

puts Solution.new(Parser.new.call).call
