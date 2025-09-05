require_relative 'base_model'

class User < BaseModel
  # La tabla se creará automáticamente cuando sea necesaria
  # o se puede crear con migraciones de Sequel
  
  # Validaciones de ejemplo
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
    errors.add(:email, 'cannot be empty') if !email || email.empty?
    errors.add(:email, 'format is invalid') if email && !email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end
  
  # Métodos de instancia de ejemplo
  def full_info
    "#{name} (#{email})"
  end
  
  # Métodos de clase de ejemplo
  def self.by_email(email)
    where(email: email).first
  end
end