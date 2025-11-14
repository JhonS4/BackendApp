# controllers/application_controller.rb
require 'sinatra/base'
require 'jwt'
require 'json'   # <- importante para parsear/retornar JSON
require_relative '../helpers/application_helper'
require_relative '../config/database'

class ApplicationController < Sinatra::Base
  helpers ApplicationHelper
  
  configure do
    set :views, File.expand_path('../views', __dir__)
    set :public_folder, File.expand_path('../public', __dir__)
    set :bind, '0.0.0.0'
    set :port, 5000

    # Configuración JWT (mejor dentro del configure)
    set :jwt_secret,     ENV['JWT_SECRET'] || 'tu_clave_super_secreta_aqui_cambiar_en_produccion'
    set :jwt_expiration, 24 * 60 * 60 # 24 horas
  end
  
  configure :development do
    set :logging, true
    set :dump_errors, true
    set :show_exceptions, true
    DB.loggers << Logger.new($stdout)
  end

  # Cargar modelos
  Dir[File.expand_path('../models/*.rb', __dir__)].each { |file| require file }

  # Ruta principal (web)
  get '/' do
    erb :index
  end

  # Helper de título (por si usan vistas)
  def page_title(title = "Aplicación Sinatra")
    @page_title = title
  end

  run! if app_file == $0
end
