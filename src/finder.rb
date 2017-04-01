class Finder
  attr_accessor :connectedComponents, :list, :visited
  attr_accessor :connected, :complete, :oddCycle, :limit
  attr_reader :n, :m, :edges

  def initialize(n, m, edges)
    @n, @m, @edges = n, m, edges
    self.createList
    self.findFeatures
    self.describeFeatures
  end

  def createList
    @list = Array.new(@n) { Array.new }
    @edges.each do |edge|
      u, v = edge
      @list[u].push(v)
      @list[v].push(u)
    end
  end

  def findFeatures
    @complete = self.isComplete
    @oddCycle = self.isOddCycle
    self.findConnectedComponents
    @connected = self.isConnected
    @limit = self.limitChromaticNumber
  end

  def describeFeatures
    print @connected ? "Connected, " : "Disconnected, "
    print @complete ? "complete graph, " : "not complete graph, "
    puts @oddCycle ? "an odd cycle" : "not an odd cycle"
    if @complete || @oddCycle
      puts "Chromatic number equals to #{@limit}"
    else
      puts "Chromatic number not greater than #{@limit}"
    end
  end

  def isComplete
    return @n * (@n - 1) == 2 * @m ? true : false
  end

  def isOddCycle
    unless @n % 2 == 1 && @n == @m
      return false
    end
    sizes = @list.map(&:size)
    sizes.each do |size|
      if size != 2
        return false
      end
    end
    return true
  end

  def findConnectedComponents
    @connectedComponents = Array.new { Array.new }
    @visited = Array.new(@n, false)
    (0...@n).each do |v|
      unless @visited[v]
        cc = Array.new
        self.search(v, cc)
        @connectedComponents.push(cc)
      end
    end
  end

  def search(u, cc)
    cc.push(u)
    @visited[u] = true
    @list[u].each do |v|
      unless @visited[v]
        self.search(v, cc)
      end
    end
  end

  def isConnected
    return @connectedComponents.size == 1 ? true : false
  end

  def countDegree
    sizes = @list.map(&:size)
    return sizes.max
  end

  def limitChromaticNumber
    degree = self.countDegree
    return @complete || @oddCycle ? degree + 1 : degree
  end
end
