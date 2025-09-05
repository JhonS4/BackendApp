require 'sequel'
require 'logger'

DB = Sequel.sqlite('db/development.sqlite3')

# Configuración de logging para desarrollo
DB.loggers << Logger.new($stdout) if defined?(Sinatra::Base) && Sinatra::Base.development?