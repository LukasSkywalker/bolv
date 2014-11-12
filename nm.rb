require 'csv'

=begin
Meisterschaftsform

Die Meisterschaft besteht aus 5 Wertungsläufen, an welchen in den 15 aufge-
führten Kategorien Punkte vergeben werden (1. Rang Frühling 25 Pt.,
Herbst 27 Pt., 2. Rang Frühling 24 Pt. Herbst 26 Pt. usw.). Pro Teilnehmer
zählen die 3 besten Resultate. Bei Punktgleichheit entscheidet der bessere
Rang am Schlusslauf.

Spezialregelung NOM

Falls einer der Wertungsläufe als Schweizer Meisterschaft im Nacht-OL NOM aus-
getragen wird, gelten für diesen Lauf folgende Regelungen:

    Es werden nur Punkte vergeben in Kategorien, die auch zur Berner Nacht-OL
    Meisterschaft zählen.
    Kategorienzusammenlegungen werden nicht berücksichtigt. In sämtlichen
    Kategorien erhält der Sieger 25 Punkte, der Zweitplatzierte 24 Punkte usw.
    Für die Vergabe der Punkte werden sämtliche klassierten Läufer berück-
    sichtigt.
    In der Gesamtrangliste der Berner Nacht-OL Meisterschaft aufgeführt werden
    nur NOM-Teilnehmer, die mindestens an einem vor der NOM durchgeführten
    Wertungslauf in der gleichen Kategorie teilgenommen haben.
=end

CATEGORIES = {
  d: {
    'D16' => 'Jugend2',
    'D18' => 'Jugend1',
    'D20' => 'DamenA',
    'DAL' => 'DamenA',
    'DAK' => 'DamenK',
    'D35' => 'Sen1',
    'D40' => 'Sen1',
    'D45' => 'Sen2',
    'D50' => 'Sen2',
    'D55' => 'Sen3',
    'D60' => 'Sen3'
  },
  h: {
    'H16' => 'Jugend2',
    'H18' => 'Jugend1',
    'H20' => 'HerrenA',
    'HAL' => 'HerrenA',
    'HAK' => 'HerrenK',
    'H35' => 'Sen1',
    'H40' => 'Sen1',
    'H45' => 'Sen2',
    'H50' => 'Sen2',
    'H55' => 'Sen3',
    'H60' => 'Sen3',
    'H65' => 'Sen4',
    'H70' => 'Sen4'
  }
}

FILES = Dir.glob('*.csv').map do |file|
  file
end

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

class Category
  attr_accessor :name, :gender  

  def initialize(name, gender)
    @name = name
    @gender = gender
    @@all ||= []
    @@all << self
  end

  def self.all
    @@all
  end

  def self.for(real_cat)
    gender = real_cat[0].downcase
    name = CATEGORIES[gender.to_sym][real_cat]
    @@all.select do |category|
      category.name == name && category.gender == gender
    end.first
  end

  def athletes
    Athlete.all.select do |athlete|
      athlete.category == self
    end.sort do |a, b|
      b.points <=> a.points
    end
  end
end

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

CATEGORIES[:d].values.uniq.each do |cat|
  Category.new(cat, 'd')
end

CATEGORIES[:h].values.uniq.each do |cat|
  Category.new(cat, 'h')
end

FILES.each do |file|
  comp_name = file.split('.').first.gsub('_', ' ')[2..-1]
  puts 'Lese ' + comp_name
  puts 'Frühling = 0, Herbst = 1?'
  comp_semester = gets.chomp.to_i
  puts 'NOM? (1=yes, nothing=no)'
  comp_nom = gets.chomp.to_i
  c = Competition.new(comp_name, comp_semester)
  CSV.foreach(File.path(file), encoding: 'iso-8859-1', col_sep: ';', headers: true) do |col|
    next if col['Kategorie'][0] == 'O'
    cat = Category.for(col['Kategorie'])
    if(comp_nom == 1)
      ath = Athlete.first(cat, col['Name'])
    else
      ath = Athlete.first_or_create(cat, col['Name'], col['Ort'], col['Club'])
    end
    next if ath.nil?
    rank = col['Rang'].to_i
    rank = 100 if rank == 0
    result = Result.new(c, ath, rank)
  end
end

CSV.open("nm.csv", "wb") do |csv|
  Category.all.each do |cat|
    csv << ["Kategorie: #{cat.name}"]
    csv << ["Rang", "Name", "Wohnort", "Verein", "Punkte"] + Competition.all.map { |comp| comp.name }
    cat.athletes.each do |ath|
      res = Competition.all.map do |comp|
        comp.points_for(ath)
      end
      csv << [0, ath.name, ath.location, ath.club, ath.points] + res
    end
    csv << []
  end
end
