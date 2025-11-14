class Vehicle < BaseModel
  set_dataset DB[:vehicles]

  many_to_one :user, key: :user_id  # conductor
  one_to_many :trips

  def validate
    super
    validates_presence [:user_id, :make, :model, :license_plate, :capacity]
  end
end
