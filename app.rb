require 'sinatra/base'
require 'sinatra/content_for'

Dir.glob('models/*.rb').each do |f|
  require_relative f
end
require_relative 'nm'

class App < Sinatra::Base
  helpers Sinatra::ContentFor
  set :erb, layout: :layout
  set :server, 'thin'

  get '/' do
    erb :index
  end

  post '/upload' do
    files = []
    (1..5).each do |i|
      name = 'file' + i.to_s
      nom = 'nom' + i.to_s
      sem = 'sem' + i.to_s

      file = params[name.to_sym]
      if file
        files << InputFile.new(file[:filename], params[nom.to_sym] == 'on', params[sem.to_sym].to_i, file[:tempfile].path) 
      end
    end
    c = Calculator.new
    @result = c.calculate(files)
    erb :result
  end
end

class InputFile
  attr_accessor :name, :nom, :path, :sem
  def initialize(name, nom, sem, path)
    @name = name
    @nom = nom
    @sem = sem
    @path = path
  end
end
