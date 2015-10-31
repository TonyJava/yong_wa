class DateString

  public
  
  def initialize(args)
    
  end
  

  def self.compare_less_or_equal a, b
    date_a = Date.strptime(a, "%Y-%m-%d")
    date_b = Date.strptime(b, "%Y-%m-%d")
    date_a <= date_b
  end

  def self.next_day a
    date_a = Date.strptime(a, "%Y-%m-%d")
    (date_a + 1.day).strftime("%Y-%m-%d")
  end
  
  def self.prev_day a
    date_a = Date.strptime(a, "%Y-%m-%d")
    (date_a - 1.day).strftime("%Y-%m-%d")  
  end

  def self.today
    Time.now.strftime("%Y-%m-%d") 
  end

  def self.now
    Time.now.strftime("%Y-%m-%d,%H:%M:%S")
  end

  def self.week_ago a
    date_a = Date.strptime(a, "%Y-%m-%d")
    (date_a - 7.day).strftime("%Y-%m-%d") 
  end
end