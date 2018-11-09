class City < Struct.new(:id, :x, :y, :deliveries)
  def difference(other)
    Math.sqrt((x - other.x)**2 + (y - other.y)**2)
  end

  def ==(other)
    id == other.id
  end
end
