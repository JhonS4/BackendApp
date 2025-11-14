# config/database.rb
require 'sequel'
require 'logger'

# Ruta absoluta al archivo carpoolu.db dentro de /db
DB = Sequel.sqlite(File.expand_path('../db/carpoolu.db', __dir__))

# Activar claves foráneas
DB.run('PRAGMA foreign_keys = ON;')

# Logging solo en desarrollo (opcional)
if defined?(Sinatra::Base) && Sinatra::Base.development?
  DB.loggers << Logger.new($stdout)
end
