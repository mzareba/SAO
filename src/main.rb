require_relative 'coloring'
require_relative 'presentation'

class Main
  attr_reader :coloring, :presentation, :technique
  attr_accessor :conflicts, :credit, :warnings

  def initialize(coloring, technique)
    @coloring, @technique = coloring, technique
    @conflicts = Array.new
    @credit = 100
    @warnings = 0
  end

  def process
    @coloring.createPopulation
    average = @coloring.countAverage.round(1)
    @conflicts.push(average)
    self.presentIterationStatus(0)
    (1..500).each do |i|
      self.applyTechnique(i)
      average = @coloring.countAverage.round(1)
      @conflicts.push(average)
      self.presentIterationStatus(i)
      self.controlProgress
      if @conflicts[-1] == 0.0 || @credit == 0 || @warnings == 10
        self.presentFinalMessage(i)
        break
      end
    end
    puts
  end

  def presentIterationStatus(i)
    if i % 50 == 0
      iteration = i == 0 ? 'start' : i
      puts "Conflicts average (#{iteration}): #{@conflicts[i]}"
    end
  end

  def applyTechnique(i)
    case @technique
    when "crossbreedV1"
      @coloring.crossbreedV1
    when "mutationV1"
      @coloring.mutationV1
    when "combinedV1"
      @coloring.crossbreedV1
      @coloring.mutationV1
    when "crossbreedV2"
      @coloring.crossbreedV2
    when "mutationV2"
      @coloring.mutationV2(i)
    when "combinedV2"
      @coloring.crossbreedV2
      @coloring.mutationV2(i)
    end
  end

  def controlProgress
    if @conflicts[-1] >= @conflicts[-2]
      @warnings += 1
      @credit -= 1
    elsif @warnings > 0
      @credit -= 1
      @warnings = 0
    end
  end

  def presentFinalMessage(i)
    puts "Completed after #{i} iterations: #{@conflicts[-1]}"
  end
end

if [1,3].include?(ARGV.size)
  coloring = Coloring.new(ARGV)
  conflicts = Array.new
  techniques = ['crossbreedV1', 'crossbreedV2', 'mutationV1', 'mutationV2', 'combinedV1', 'combinedV2']
  techniques.each do |technique|
    puts "Selected technique: #{technique}"
    main = Main.new(coloring, technique)
    main.process
    conflicts.push(main.conflicts)
  end
  presentation = Presentation.new(conflicts, techniques)
  presentation.create
else
  puts "Syntax: ruby main.rb n m k | ruby main.rb filename"
end
