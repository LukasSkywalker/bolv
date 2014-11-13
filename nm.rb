require 'csv'
require_relative 'models/categories'

class Calculator
  def calculate(files)
    Athlete.clear
    Category.clear
    Competition.clear
    Result.clear
    CATEGORIES[:d].values.uniq.each do |cat|
      Category.new(cat, 'd')
    end

    CATEGORIES[:h].values.uniq.each do |cat|
      Category.new(cat, 'h')
    end
    files.each do |file|
      comp_name = file.name.split('.').first[2..-1]
      puts 'Lese ' + comp_name
      comp_semester = file.sem
      comp_nom = file.nom
      c = Competition.new(comp_name, comp_semester)
      CSV.foreach(file.path, encoding: 'iso-8859-1', col_sep: ';', headers: true) do |col|
        next if col['Kategorie'][0] == 'O'
        cat = Category.for(col['Kategorie'])
        if(comp_nom == true)
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
    csv = '<table>'
    Category.all.each do |cat|
      csv << "<tr><td>Kategorie: #{cat.name}</td></tr>"
      csv << "<tr><td>" + ["Rang", "Name", "Wohnort", "Verein", "Punkte"].join("</td><td>") + '</td><td>' + Competition.all.map { |comp| comp.name }.join("</td><td>") + '</td></tr>'
      rang = 0
      last_points = 9999
      offset = 1
      cat.athletes.each do |ath|
        if ath.points < last_points
          rang += offset
          offset = 1
        else
          offset += 1
        end
        last_points = ath.points
        res = Competition.all.map do |comp|
          comp.points_for(ath)
        end
        csv << "<tr><td>#{rang}</td><td>#{ath.name}</td><td>#{ath.location}</td><td>#{ath.club}</td><td>#{ath.points}</td><td>" + res.join("</td><td>") + '</td></tr>'
      end
    end
    csv << '</table>'
  return csv
  end
end
