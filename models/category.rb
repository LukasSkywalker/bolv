require_relative 'categories'

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
