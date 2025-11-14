# models/review.rb
require_relative 'base_model'

class Review < BaseModel
    set_dataset DB[:reviews]

    # conexiones
    many_to_one :reviewer, class: 'User', key: :reviewer_id
    many_to_one :reviewee, class: 'User', key: :reviewed_user_id
    many_to_one :trip, class: 'Trip', key: :trip_id

    def validate
        super
        # Campos requeridos
        validates_presence [:reviewer_id, :reviewed_user_id, :rating, :trip_id]
        
        # Rating entre 1-5
        validates_includes 1..5, :rating

        # Limite comment
        validates_max_length 500, :comment if comment

        # no review a ti mismo xd
        if reviewer_id == reviewed_user_id
            errors.add(:reviewed_user_id, "No puedes evaluarte a ti mismo :v")
        end
    end

    # Atributos publicos para responses api (matches frontend)
    def public_attributes
        {
            id: id,
            rating: rating,
            comment: comment,
            is_anonymous: is_anonymous,
            reviewer: reviewer_info,
        }
    end

    private

    def reviewer_info
        if is_anonymous
            {first_name: "Usuario", last_name: "Anonimo", profile_picture: nil}
        else
            {
                id: reviewer&.id,
                first_name: reviewer&.first_name,
                last_name: reviewer&.last_name,
                profile_picture: reviewer&.profile_picture
            }
        end
    end

    # algo
    def time_ago_in_words
        return "" unless created_at

        seconds = (Time.now - created_at).to_i 
        case seconds
        when 0...60 then "Hace unos segundos"
        when 60...3600 then "Hace #{seconds / 60} minutos"
        when 3600...86400 then "Hace #{seconds / 3600} horas"
        when 86400...604800 then "Hace #{seconds / 86400} días"
        else "Hace #{seconds / 604800} semanas"
        end
    end
end
