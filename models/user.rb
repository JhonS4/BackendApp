# models/user.rb
require_relative 'base_model'

class User < BaseModel
  # Por claridad, fijamos explícitamente la tabla
  set_dataset DB[:users]

  # === ADD ASSOCIATIONS HERE ===
  # A user has many reviews they GAVE (as a reviewer)
  one_to_many :given_reviews, class: 'Review', key: :reviewer_id
  
  # A user has many reviews they RECEIVED (as a reviewed_user)  
  one_to_many :received_reviews, class: 'Review', key: :reviewed_user_id
  # === END ASSOCIATIONS ===

  def validate
    super
    # Campos obligatorios
    validates_presence [:first_name, :last_name, :email, :password_hash]

    # Email único
    validates_unique :email

    # Longitudes máximas
    validates_max_length 100, :first_name
    validates_max_length 100, :last_name
    validates_max_length 255, :email
  end

  # Método de clase para buscar por credenciales (login)
  def self.find_by_credentials(email, password_hash)
    select(
      :id, :first_name, :last_name, :email, :profile_picture, :gender,
      :rating, :total_ratings, :is_verified, :is_active
    ).where(
      email: email,
      password_hash: password_hash,
      is_active: true
    ).first
  end

  # Atributos “seguros” para exponer hacia el frontend
  def public_attributes
    {
      id: id,
      first_name: first_name,
      last_name: last_name,
      email: email,
      profile_picture: profile_picture,
      gender: gender,
      rating: rating,
      total_ratings: total_ratings,
      is_verified: is_verified,
      is_active: is_active
    }
  end
end