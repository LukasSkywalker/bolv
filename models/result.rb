class Result
  attr_accessor :competition, :category, :athlete, :rank, :time
  def initialize(competition, category, athlete, rank, time)
    @competition = competition
    @category = category
    @athlete = athlete
    @rank = rank
    @time = time
    @@all ||= []
    @@all << self
  end

  def self.all
    @@all
  end

  def self.clear
    @@all = []
  end

  def self.by_athlete(athlete)
    @@all ||= []
    @@all.select do |result|
      result.athlete == athlete
    end
  end

  def points
    cat_results = Result.all.select{ |result| result.competition == competition && result.category == category }
    cat_ranking = cat_results.sort do |a, b|
      TimeLib.parse_time(a.time) <=> TimeLib.parse_time(b.time)
    end
    idx = cat_ranking.index(self)
    rnk = idx + 1
    [competition.max_points + 1 - rnk, 0].max
  end
end
