# Helper class to calculate if two dates are arranged in different time intervals.
class TimeIntervalDiffer

  attr_accessor :resolution
  
  INTERVALS = [1, 60, 1440, 43800, 525600]
  NAMES = [:min, :hour, :day, :mon, :year]
  
  def initialize(resolution)
    @resolution = resolution
    @new_interval = false
  
    @interval_info = find_interval
  end
  
  # Adds a new date.
  def <<(time)
    
    # get relevant time element
    unit = time.send(@interval_info[:look_in])
    @change = unit/@interval_info[:step]
    
    # Ist das neue Datum in einem neuen Intervall?
    @new_interval = @last_change != @change if @last_change != nil
    
    @last_change = @change
  end
  
  # Checks if the last date reachs a new time interval. The interval is defined by the given resolution.
  def new_interval?
    @new_interval
  end
  
  private
  
  # Calculates the interval informations with the given resolution. The interval informations 
  # help to check, if two dates are arranged in different time intervals.
  def find_interval

    look_in, step = nil, nil
    
    i = 0
    INTERVALS.each do |interval|
      if interval.to_f / @resolution > 1
        # interval found
        look_in = NAMES[i-1]
        step = @resolution / INTERVALS[i-1]
        break
      end
      i += 1
    end
    
    # Jahr
    if look_in == nil
      look_in = NAMES.last
      step = @resolution / INTERVALS.last
    end
    
    {look_in: look_in, step: step}
  end
  
end
