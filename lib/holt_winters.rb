#
# Time series Forecasting using Holt-Winters Exponential Smoothing
# @see http://static.usenix.org/events/lisa00/full_papers/brutlag/brutlag_html/
# @see http://www.evanmiller.org/poisson.pdf
#
class HoltWinters
  attr_reader :alpha, :beta, :gamma, :seasonal_values
  
  module FilteringType
    SIMPLE = 1
    DOUBLE = 2
    TRIPLE = 3
  end

  def initialize(alpha, beta=nil, gamma=nil, period=0)
    @value = nil
    @alpha = alpha
    @beta = beta
    @gamma = gamma
    @baseline = nil
    @slope = nil
    @seasonal_values = nil
    @num_seen = 0
    if period > 0
      @seasonal_values = Array.new(period, 0.0)
    end
  end

  def get_deviation()
    (@value && @last_forecast) ? (@value - @last_forecast).abs : nil
  end

  def add_next_value(value)
    @last_forecast = get_forecast(1)
    @value = value
    update_parameters()
    @num_seen += 1
  end
end

class HoltWintersSimple < HoltWinters
  def initialize(alpha)
    super(alpha)
  end

  def get_forecast(h)
    @num_seen < 2 ? nil : @baseline
  end

  private
  def update_parameters()
    if @num_seen == 0
      @baseline = @value
    else
      old_baseline = @baseline
      @baseline = @alpha * @value + (1.0 - @alpha) * old_baseline
    end
  end
end

class HoltWintersDouble < HoltWinters
  def initialize(alpha, beta)
    super(alpha, beta)
  end

  def get_forecast(h)
    @num_seen < 3 ? nil : @baseline + h * @slope
  end

  private
  def update_parameters()
    if @num_seen == 0
      @baseline = @value
    elsif @num_seen == 1
      @slope = @value - @baseline
      @baseline = @value
    else
      old_baseline = @baseline
      old_slope = @slope
      @baseline = @alpha * @value + (1.0 - @alpha) * (old_baseline + old_slope);
      @slope = @beta * (@baseline - old_baseline) + (1.0 - @beta) * old_slope;
    end
  end
end

class HoltWintersTriple < HoltWinters
  def initialize(alpha, beta, gamma, period)
    super(alpha, beta, gamma, period)
  end

  def get_forecast(h)
    return nil if @num_seen < 3
    l = @seasonal_values.length
    return @baseline + h * @slope + @seasonal_values[(l-1+(h-1)%l) % l];
  end

  def update_parameters()
    len = @seasonal_values.length
    if @num_seen == 0
      @baseline = @value
      @seasonal_values[@num_seen] = @value
    elsif @num_seen == 1
      @slope = @value - @baseline
      @baseline = @value
      @seasonal_values[@num_seen] = @value
    elsif @num_seen < len
      @seasonal_values[@num_seen] = @value
    else
      old_baseline = @baseline
      old_slope = @slope
      old_seasonal = @seasonal_values[0]
      @seasonal_values = @seasonal_values.shift.push(nil)
      @baseline = @alpha * (@value - old_seasonal) + (1.0 - @alpha) * (old_baseline + old_slope);
      @slope = @beta * (@baseline - old_baseline) + (1.0 - @beta) * old_slope;
      @seasonal_values[len-1] = @gamma * (@value - @baseline) + (1.0 - @gamma) * old_seasonal;
    end
  end
end

# h = HoltWintersFactory.create(0.5, :beta => 0.3, :gamma => 0.1, :period => 4)
# h.add_next_value(3)
# h.add_next_value(3)
# h.add_next_value(3)
# h.add_next_value(3)
# h.add_next_value(3)
# h.add_next_value(3)
# h.add_next_value(3)
# h.add_next_value(3)
# p h
# p h.get_deviation
# h.add_next_value(5)
# h.add_next_value(5)
# h.add_next_value(5)
# p h
# p h.get_deviation
# h.add_next_value(15)
# h.add_next_value(15)
# h.add_next_value(15)
# p h
# p h.get_deviation
# h.add_next_value(45)
# p h
# p h.get_deviation
