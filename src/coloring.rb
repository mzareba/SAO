require_relative 'creator'
require_relative 'finder'

class Coloring
  attr_accessor :list, :edges, :population
  attr_accessor :connectedComponents, :visited
  attr_accessor :n, :m, :k
  attr_reader :name

  def initialize(input)
    creator = Creator.new
    if input.size == 3
      @n, @m, @k = input.map(&:to_i)
      @edges = creator.generateInput(@n, @m)
    else
      file = '../input/' + input[0]
      @n, @m, @k, @edges = creator.parseInput(file)
    end
    finder = Finder.new(@n, @m, @edges)
  end

  def createPopulation(size)
    @population = Array.new(size) { Array.new(@n, nil) }
    @population = @population.map { |colors|
      colors.map { |color| Random.new.rand(0...@k) }
    }
  end

  def countConflicts(colors)
    conflicts = 0
    @edges.each do |edge|
      u, v = edge
      if colors[u] == colors[v]
        conflicts += 1
      end
    end
    return conflicts
  end

  def countAverage
    conflicts = 0
    @population.each do |colors|
      conflicts += self.countConflicts(colors)
    end
    return conflicts.to_f / @population.length
  end

  def selectCandidates
    average = self.countAverage
    @population.each do |colors|
      if self.countConflicts(colors) > average
        @population.delete(colors)
      end
    end
  end

  def crossbreed(size)
    successors = Array.new { Array.new(@n, nil) }
    size.times do
      i, j = Array.new(2) { Random.new.rand(0...@population.length) }
      successor = self.createSuccessor(@population[i], @population[j])
      successors.push(successor)
    end
    @population = successors
  end

  def createSuccessor(first, second)
    successor = Array.new(@n, nil)
    (0...@n).each do |i|
      selected = [0, 1].sample
      successor[i] = selected == 0 ? first[i] : second[i]
    end
    return successor
  end
end
