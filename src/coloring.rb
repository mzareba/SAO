require_relative 'creator'
require_relative 'finder'

class Coloring
  attr_accessor :list, :edges, :population, :points
  attr_accessor :connectedComponents, :visited
  attr_accessor :n, :m, :k
  attr_reader :size

  def initialize(input)
    creator = Creator.new
    if input.size == 3
      @n, @m, @k = input.map(&:to_i)
      @edges = creator.generateInput(@n, @m)
    else
      file = 'input/' + input[0]
      @n, @m, @k, @edges = creator.parseInput(file)
    end
    finder = Finder.new(@n, @m, @edges)
    @size = 500
  end

  def createPopulation
    @population = Array.new(@size) { Array.new(@n, nil) }
    @population = @population.map { |colors|
      colors = colors.map { |color| Random.new.rand(0...@k) }
      colors = self.getCanonicalForm(colors)
    }
    @points = Array.new(@size, 0)
  end

  def getCanonicalForm(colors)
    switch = Array.new(@k, nil)
    color = 0
    (0...n).each do |i|
      j = colors[i]
      if switch[j].nil?
        switch[j] = color
        color += 1
      end
      colors[i] = switch[j]
    end
    return colors
  end

  def countConflicts(colors)
    counter = 0
    @edges.each do |edge|
      u, v = edge
      if colors[u] == colors[v]
        counter += 1
      end
    end
    return counter
  end

  def countAverage
    counter = 0
    @population.each do |colors|
      counter += self.countConflicts(colors)
    end
    return counter.to_f / @population.length
  end

  def countPoints
    length = @population.length
    personal = Array.new(length)
    @population.each_with_index do |colors, index|
      personal[index] = self.countConflicts(colors)
    end
    min, max = personal.minmax
    if min == max
      @points = Array.new(length, 1)
      return true
    end
    @points = personal.map { |num| (num - min).to_f / (max - min).to_f }
    @points = @points.map { |score| (10 * (1-score)).to_i }
    # @points = @points.map { |score| 7 - (Math.log(101-score, 2).to_i) }
  end

  def qualifyCandidates
    average = self.countAverage
    @population.each do |colors|
      if self.countConflicts(colors) > average
        @population.delete(colors)
      end
    end
  end

  def crossbreedV1
    self.qualifyCandidates
    successors = Array.new { Array.new(@n, nil) }
    @size.times do
      i, j = Array.new(2) { Random.new.rand(0...@population.length) }
      successor = self.createSuccessor(@population[i], @population[j])
      successor = self.getCanonicalForm(successor)
      successors.push(successor)
    end
    @population = successors
  end

  def crossbreedV2
    self.countPoints
    successors = Array.new { Array.new(@n, nil) }
    length = @population.length
    cards = Array.new
    (0...length).each do |i|
      cards += Array.new(@points[i], i)
    end
    @size.times do
      i, j = Array.new(2) { Random.new.rand(0...cards.length) }
      first, second = cards[i], cards[j]
      successor = self.createSuccessor(@population[first], @population[second])
      successor = self.getCanonicalForm(successor)
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

  def selectCandidates
    selected = Array.new { Array.new }
    (0...@population.length).each_with_index do |colors, index|
      dice = (1..100).to_a.sample
      if dice == 1
        selected.push(index)
      end
    end
    return selected
  end

  def mutationV1
    self.qualifyCandidates
    self.selectCandidates.each do |v|
      colors = @population[v]
      i, j = Array.new(2) { Random.new.rand(0...@n) }
      colors[i], colors[j] = colors[j], colors[i]
      @population[v] = self.getCanonicalForm(colors)
    end
  end

  def mutationV2(iteration)
    self.qualifyCandidates
    log = Math.log(@size / iteration, 3).to_i
    card = [log + 2, @n].min
    self.selectCandidates.each do |v|
      colors = @population[v]
      before = Array.new(card) { Random.new.rand(0...@n) }
      after = before.shuffle
      saved = Array.new(@n)
      before.each_with_index do |item, index|
        saved[index] = colors[item]
      end
      after.each_with_index do |item, index|
        colors[item] = saved[index]
      end
      @population[v] = self.getCanonicalForm(colors)
    end
  end
end
