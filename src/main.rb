require_relative 'coloring'
require_relative 'presentation'

class Main
  attr_reader :coloring, :presentation, :technique
  attr_accessor :conflicts, :tolerance, :warnings

  def initialize(coloring, technique)
    @coloring, @technique = coloring, technique
    @conflicts = Array.new
    @tolerance = 20
    @warnings = 0
  end

  def process
    @coloring.createPopulation(500)
    self.presentIterationStatus(0)
    @conflicts.push(@coloring.countAverage)
    (1..500).each do |i|
      size = @coloring.selectCandidates
      self.applyTechnique
      @conflicts.push(@coloring.countAverage)
      self.presentIterationStatus(i)
      self.controlProgress
      if @conflicts[-1] == 0.0 || @warnings == @tolerance
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
      @coloring.crossbreed(500)
    when "mutation"
      @coloring.mutate
    when "combined"
      @coloring.crossbreed(500)
      @coloring.mutate
    end
  end

  def controlProgress
    if @conflicts[-1] >= @conflicts[-2] - 0.05
      @warnings += 1
    elsif @warnings > 0
      @tolerance = @tolerance > 5 ? @tolerance - 1 : 5
      @warnings = 0
    end
  end

  def presentFinalMessage(i)
    puts "Completed after #{i} iterations (#{@conflicts[-1]})"
  end
end

if [1,3].include?(ARGV.size)
  coloring = Coloring.new(ARGV)
  conflicts = Array.new
  techniques = ['crossbreed', 'mutation', 'combined']
  techniques.each do |technique|
    puts "Selected technique: #{technique}"
    main = Main.new(coloring, "combined")
    main.process
    conflicts.push(main.conflicts)
  end
  presentation = Presentation.new(conflicts, techniques)
  presentation.create
else
  puts "Syntax: ruby main.rb n m k | ruby main.rb filename"
end
