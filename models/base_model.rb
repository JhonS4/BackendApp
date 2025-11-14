require 'sequel'

# Clase base para todos los modelos
class BaseModel < Sequel::Model
  # Configuraciones comunes para todos los modelos
  plugin :json_serializer
  
  def before_create
    super
    self.created_at ||= Time.now if respond_to?(:created_at)
  end

  def before_update
    super
    self.updated_at = Time.now if respond_to?(:updated_at)
  end
end