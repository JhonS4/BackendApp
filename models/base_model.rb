# models/base_model.rb
require 'sequel'
require_relative '../config/database'

class BaseModel < Sequel::Model(DB)
  # Activamos helpers de validación (validates_presence, etc.)
  plugin :validation_helpers

  # Si quieres timestamps automáticos (created_at / updated_at)
  # plugin :timestamps, update_on_create: true
end