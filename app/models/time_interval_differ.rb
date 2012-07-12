# helper class to calculate the time between to dates

class TimeIntervalDiffer

  attr_accessor :resolution
  
  INTERVALS = [1, 60, 1440, 43800, 525600]
  NAMES = [:min, :hour, :day, :mon, :year]

  def initialize(resolution)
    @resolution = resolution
    @new_interval = false
  end
  
  def <<(time)
  
    res = self.find_interval
    
    # Methode an Time aufrufen (gibt Tag, Monat, Jahr, Stunde, .. zurueck)
    unit = time.send(res[:look_in]) # z.B. time.day
    @change = unit/res[:step]
    
    @new_interval = @last_change != @change if @last_change != nil
    
    @last_change = @change
  end
  
  def new_interval?
    @new_interval
  end
  
  protected
  
  def find_interval

    look_in, step = nil, nil
    
    i = 0
    INTERVALS.each do |interval|

      if interval.to_f / @resolution > 1
        # interval found
        look_in = NAMES[i-1]
        step = @resolution / INTERVALS[i-1]
        #innerhalb_von = names[i]
        
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
