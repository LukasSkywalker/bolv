class Competition
  attr_accessor :name, :semester
  def initialize(name, semester)
    @name = name
    @semester = semester
    @@all ||= []
    @@all << self
  end

  def self.all
    @@all ||= []
    @@all
  end

  def max_points
    if semester == 0
      return 25
    elsif semester == 1
      return 27
    else
      raise StandardError, 'Semester not defined'
    end
  end
  
  def points_for(athlete)
    res = Result.by_athlete(athlete).select{ |result| result.competition == self }.first
    return 0 if res.nil?
    res.points
  end
end
