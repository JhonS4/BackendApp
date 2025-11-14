class Trip < BaseModel
  plugin :validation_helpers     # 👈 NECESARIO PARA validates_presence

  set_dataset DB[:trips]

  many_to_one :driver,  class: :User,   key: :driver_id
  many_to_one :vehicle, class: :Vehicle, key: :vehicle_id
  one_to_many :bookings

  def validate
    super
    validates_presence [
      :driver_id,
      :vehicle_id,
      :origin_address,
      :destination_address,
      :departure_datetime,
      :available_seats,
      :price_per_seat
    ]
  end

  def booked_seats
    bookings_dataset.sum(:seats_reserved) || 0
  end

  def remaining_seats
    available_seats - booked_seats
  end
end
