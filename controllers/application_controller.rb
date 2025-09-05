require 'sinatra/base'
require_relative '../config/database'

class ApplicationController < Sinatra::Base
  configure do
    set :views, File.expand_path('../views', __dir__)
    set :public_folder, File.expand_path('../public', __dir__)
    set :bind, '0.0.0.0'
    set :port, 5000
  end
  
  configure :development do
    set :logging, true
    set :dump_errors, true
    set :show_exceptions, true
  end

  # Cargar modelos (se pueden cargar individualmente según sea necesario)
  # Dir[File.expand_path('../models/*.rb', __dir__)].each { |file| require file }

  # Ruta principal
  get '/' do
    erb :index
  end

  # Método helper para establecer el título de página
  def page_title(title = "Aplicación Sinatra")
    @page_title = title
  end

  # Ejecutar la aplicación si este archivo es ejecutado directamente
  run! if app_file == $0
end