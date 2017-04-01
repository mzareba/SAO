require_relative 'coloring'

class Main
  attr_reader :coloring

  def initialize(coloring)
    @coloring = coloring
  end

  def firstMethod
    @coloring.createPopulation(1000)
    puts "Initial population size: #{@coloring.population.length}"
    puts "Conflicts average: #{@coloring.countAverage}"
    (1..200).each do |i|
      @coloring.selectCandidates
      if i % 25 == 0
        puts "Iteration #{i}: selected #{@coloring.population.length} candidates"
      end
      @coloring.crossbreed(1000)
      if @coloring.countAverage == 0.0
        puts "Completed after #{i} iterations"
        break
      end
      if i % 25 == 0
        puts "Conflicts average: #{@coloring.countAverage}"
      end
    end
    puts
  end
end

if [1,3].include?(ARGV.size)
  coloring = Coloring.new(ARGV)
  main = Main.new(coloring)
  main.firstMethod
else
  puts "Syntax: ruby main.rb n m k | ruby main.rb filename"
end
