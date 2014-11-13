class Athlete
  attr_accessor :name, :category, :location, :club

  def initialize(category, name, location, club)
    @category = category
    @name = name
    @location = location
    @club = club
    @@all ||= []
    @@all << self
  end

  def self.all
    @@all
  end

  def self.clear
    @@all = []
  end

  def self.first_or_create(category, name, location, club)
    @@all ||= []
    a = @@all.select do |athlete|
      athlete.category == category && athlete.name == name
    end.first
    if a.nil?
      a = Athlete.new(category, name, location, club)
    end
    a
  end

  def self.first(category, name)
    @@all ||= []
    @@all.select do |athlete|
      athlete.category == category && athlete.name == name
    end.first
  end

  def points
    Competition.all.sort { |a,b| b.points_for(self) <=> a.points_for(self) }[0...3].inject(0) { |a, e| a + e.points_for(self) }
  end

  def ranks
    results.inject(0) { |a,e| a + e.rank }
  end
  
  def results
    Result.by_athlete(self)
  end
  
  def to_s
    "#{name}: #{points} points"
  end
end
