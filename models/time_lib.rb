class TimeLib
  def self.invalid
    10_000
  end
  
  def self.parse_time(t)
    parts = t.split(':')
    sep = parts.count - 1
    if sep == 0
      TimeLib.invalid
    elsif sep == 1
      m = parts[0]
      s = parts[1]
      m.to_i * 60 + s.to_i
    elsif sep == 2
      h = parts[0]
      m = parts[1]
      s = parts[2]
      h.to_i * 3600 + m.to_i * 60 + s.to_i
    end
  end
end
