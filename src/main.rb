require_relative 'coloring'

def process(coloring)
  puts "Processing #{coloring.input}"
  coloring.parseInput
  coloring.createPopulation(1000)
  puts "Initial population size: #{coloring.population.length}"
  puts "Conflicts average: #{coloring.countAverage}"
  (1..100).each do |i|
    coloring.selectCandidates
    if i % 10 == 0
      puts "Iteration #{i}: selected #{coloring.population.length} candidates"
    end
    coloring.crossbreed(1000)
    if coloring.countAverage == 0.0
      puts "Completed after #{i} iterations"
      break
    end
    if i % 10 == 0
      puts "Conflicts average: #{coloring.countAverage}"
    end
  end
  puts
end

inputs = ['input1.txt', 'input2.txt', 'input3.txt', 'input4.txt']
instances = inputs.map { |input| Coloring.new(input) }

instances.each do |instance|
  process(instance)
end
