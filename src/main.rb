require_relative 'coloring'

class Main
  attr_reader :coloring, :technique

  def initialize(coloring, technique)
    @coloring, @technique = coloring, technique
  end

  def process
    @coloring.createPopulation(100)
    self.presentIterationStatus(0)
    (1..3000).each do |i|
      size = @coloring.selectCandidates
      self.applyTechnique
      self.presentIterationStatus(i)
      if @coloring.countAverage == 0.0
        self.presentFinalMessage(i)
        break
      end
    end
    puts
  end

  def presentIterationStatus(i)
    if i % 50 == 0
      print i == 0 ? "Initial population size: " : "Iteration #{i}: "
      puts "selected #{@coloring.population.length} candidates"
      puts "Conflicts average: #{@coloring.countAverage}"
    end
  end

  def applyTechnique
    case @technique
    when "crossbreed"
      @coloring.crossbreed(100)
    when "mutation"
      @coloring.mutate
    when "combined"
      @coloring.crossbreed(100)
      @coloring.mutate
    end
  end

  def presentFinalMessage(i)
    puts "Completed after #{i} iterations"
  end
end

if [1,3].include?(ARGV.size)
  coloring = Coloring.new(ARGV)
  main = Main.new(coloring, "combined")
  main.process
else
  puts "Syntax: ruby main.rb n m k | ruby main.rb filename"
end
