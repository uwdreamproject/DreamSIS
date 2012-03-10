class Array
  
  # Calculates the average (mathematical mean) of all Numeric items in this Array.
  def average
    numeric_items.sum.to_f/numeric_items.size.to_f
  end

  # Calculates the population variance of the Numeric items in this Array.
  def variance
    n = 0
    mean = 0.0
    s = 0.0
    numeric_items.each { |x|
      n = n + 1
      delta = x - mean
      mean = mean + (delta / n)
      s = s + delta * (x - mean)
    }
    # if you want to calculate std deviation of a sample change this to "s / (n-1)"
    return s / n
  end

  # Calculate the popuplation standard deviation (square root of variance) of the Numeric items in this Array
  def standard_deviation
    Math.sqrt(variance)
  end  
  
  # Calculates the spread (difference between maximum and minimum values) of the Numeric items in this array.
  def spread
    numeric_items.max - numeric_items.min
  end
  
  # Returns a new array with all non-Numeric objects removed.
  def numeric_items
    self.select{|x| x.is_a?(Numeric)}
  end
  
end
