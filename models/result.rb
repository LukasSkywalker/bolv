class Result
  attr_accessor :competition, :athlete, :rank
  def initialize(competition, athlete, rank)
    @competition = competition
    @athlete = athlete
    @rank = rank
    @@all ||= []
    @@all << self
  end

  def self.by_athlete(athlete)
    @@all ||= []
    @@all.select do |result|
      result.athlete == athlete
    end
  end

  def points
    [competition.max_points + 1 - rank, 0].max
  end
end
