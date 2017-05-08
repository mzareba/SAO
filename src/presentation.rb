require 'gchart'

class Presentation
  attr_reader :conflicts, :length, :max, :legend

  def initialize(conflicts, techniques)
    @length = conflicts.map(&:length).max
    @max = conflicts.map(&:max).max
    @conflicts = prepareData(conflicts)
    @legend = techniques
  end

  def create
    x_labels = (0..15).map { |i| @length * i/15 }
    y_labels = (0..10).map { |i| (@max * i/10).round(1) }
    chart = Gchart.new(
      :axis_with_labels => [['x'], ['y']],
      :axis_labels => [x_labels, y_labels],
      :bar_colors => ['ff0000', 'c6035e', '0000ff', '0088ff', '1c7539', '00ff00'],
      :data => @conflicts,
      :filename => 'chart.png',
      :legend => @legend,
      :max_value => @y_top,
      :min_value => 0,
      :size => '700x400',
      :type => 'line'
    )
    chart.file
  end

  def prepareData(conflicts)
    return conflicts.map { |result|
      diff = @length - result.length
      result += Array.new(diff, nil)
    }
  end
end
