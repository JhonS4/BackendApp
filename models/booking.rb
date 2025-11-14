# models/booking.rb
class Booking < BaseModel
  # 👇 Necesario para poder usar validates_presence, validates_integer, etc.
  plugin :validation_helpers

  set_dataset DB[:bookings]

  many_to_one :trip
  many_to_one :passenger, class: :User, key: :passenger_id

  def validate
    super

    # Campos obligatorios
    validates_presence [:trip_id, :passenger_id, :seats_reserved, :total_price]

    # seats_reserved debe ser entero y >= 1
    validates_integer :seats_reserved
    if seats_reserved && seats_reserved.to_i < 1
      errors.add(:seats_reserved, 'debe ser al menos 1')
    end
  end
end
