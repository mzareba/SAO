class Creator
  def parseInput(file)
    n, m, k, edges = nil
    File.readlines(file).each do |line|
      line = line.split.map { |x| x.to_i }
      if n.nil?
        n, m, k = line
        edges = Array.new { Array.new }
      else
        u, v = line
        edges.push([u, v])
      end
    end
    return [n, m, k, edges]
  end

  def generateInput(n, m)
    edges = Array.new { Array.new }
    diff = m
    1000.times do
      self.generatePairs(n, diff, edges)
      edges = edges.uniq
      diff = m - edges.size
      break if diff == 0
    end
    if diff != 0
      abort("Input rejected")
    end
    return edges
  end

  def generatePairs(n, size, edges)
    size.times do
      u, v = Array.new(2) { Random.new.rand(0...n) }
      if u != v
        edges.push([u, v])
      end
    end
  end
end
