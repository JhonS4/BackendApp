# controllers/reviews_controller.rb
require 'sinatra/base'
require_relative 'application_controller'

class ReviewsController < ApplicationController
  # GET /api/v1/users/:user_id/reviews
  # Get all reviews received by a specific user (for the reviews page)
  get '/api/v1/users/:user_id/reviews' do
    content_type :json

    begin
      user_id = params[:user_id].to_i
      
      # Find the user using DB directly (matching your TripController pattern)
      user = DB[:users][id: user_id]
      unless user
        status 404
        return {
          success: false,
          message: "Usuario no encontrado",
          data: nil,
          error: "No se encontró el usuario con ID: #{user_id}"
        }.to_json
      end

      # Get all reviews this user received using DB directly
      reviews = DB[:reviews].where(reviewed_user_id: user_id)
                           .order(Sequel.desc(:created_at))
                           .all

      # Format the response data
      reviews_data = reviews.map do |review|
        reviewer = DB[:users][id: review[:reviewer_id]]
        
        {
          id: review[:id],
          rating: review[:rating],
          comment: review[:comment],
          created_at: review[:created_at],
          is_anonymous: review[:is_anonymous],
          reviewer: if review[:is_anonymous]
            { first_name: "Usuario", last_name: "Anónimo", profile_picture: nil }
          else
            reviewer ? {
              id: reviewer[:id],
              first_name: reviewer[:first_name],
              last_name: reviewer[:last_name],
              profile_picture: reviewer[:profile_picture]
            } : nil
          end,
          time_ago: time_ago_in_words(review[:created_at])
        }
      end

      {
        success: true,
        message: "Reseñas obtenidas exitosamente",
        data: {
          user: {
            id: user[:id],
            first_name: user[:first_name],
            last_name: user[:last_name],
            profile_picture: user[:profile_picture],
            rating: user[:rating],
            total_ratings: user[:total_ratings]
          },
          reviews: reviews_data
        },
        error: nil
      }.to_json

    rescue => e
      puts "Error obteniendo reseñas: #{e.message}"
      puts e.backtrace.join("\n")
      status 500
      {
        success: false,
        message: "Error al obtener reseñas",
        data: nil,
        error: e.message
      }.to_json
    end
  end

  # POST /api/v1/reviews
  # Create a new review
  post '/api/v1/reviews' do
    content_type :json

    begin
      request_body = JSON.parse(request.body.read, symbolize_names: true)

      # Required fields
      required_fields = [:reviewer_id, :reviewed_user_id, :trip_id, :rating]
      missing_fields = required_fields.select { |field| request_body[field].to_s.empty? }

      unless missing_fields.empty?
        status 400
        return {
          success: false,
          message: "Campos incompletos",
          data: nil,
          error: "Faltan campos requeridos: #{missing_fields.join(', ')}"
        }.to_json
      end

      # Check if reviewer and reviewee exist
      reviewer = DB[:users][id: request_body[:reviewer_id]]
      reviewee = DB[:users][id: request_body[:reviewed_user_id]]
      trip = DB[:trips][id: request_body[:trip_id]]

      unless reviewer && reviewee && trip
        status 404
        return {
          success: false,
          message: "Usuario o viaje no encontrado",
          data: nil,
          error: "No se pudo encontrar uno o más recursos"
        }.to_json
      end

      # Check if user is reviewing themselves
      if request_body[:reviewer_id] == request_body[:reviewed_user_id]
        status 422
        return {
          success: false,
          message: "No puedes evaluarte a ti mismo",
          data: nil,
          error: "El revisor y el evaluado no pueden ser la misma persona"
        }.to_json
      end

      # Check if rating is valid
      rating = request_body[:rating].to_i
      unless (1..5).include?(rating)
        status 422
        return {
          success: false,
          message: "Calificación inválida",
          data: nil,
          error: "La calificación debe estar entre 1 y 5 estrellas"
        }.to_json
      end

      # Create the review using DB directly
      review_id = DB[:reviews].insert(
        reviewer_id: request_body[:reviewer_id],
        reviewed_user_id: request_body[:reviewed_user_id],
        trip_id: request_body[:trip_id],
        rating: rating,
        comment: request_body[:comment],
        is_anonymous: request_body[:is_anonymous] || false,
        created_at: Time.now,
        updated_at: Time.now
      )

      # Get the created review
      new_review = DB[:reviews][id: review_id]
      reviewer_user = DB[:users][id: new_review[:reviewer_id]]

      review_data = {
        id: new_review[:id],
        rating: new_review[:rating],
        comment: new_review[:comment],
        created_at: new_review[:created_at],
        is_anonymous: new_review[:is_anonymous],
        reviewer: if new_review[:is_anonymous]
          { first_name: "Usuario", last_name: "Anónimo", profile_picture: nil }
        else
          reviewer_user ? {
            id: reviewer_user[:id],
            first_name: reviewer_user[:first_name],
            last_name: reviewer_user[:last_name],
            profile_picture: reviewer_user[:profile_picture]
          } : nil
        end,
        time_ago: time_ago_in_words(new_review[:created_at])
      }

      status 201
      {
        success: true,
        message: "Reseña creada exitosamente",
        data: review_data,
        error: nil
      }.to_json

    rescue JSON::ParserError => e
      status 400
      {
        success: false,
        message: "JSON inválido",
        data: nil,
        error: e.message
      }.to_json
    rescue => e
      puts "Error creando reseña: #{e.message}"
      puts e.backtrace.join("\n")
      status 500
      {
        success: false,
        message: "Error al crear reseña",
        data: nil,
        error: e.message
      }.to_json
    end
  end

  private

  # Helper to show "Hace 2 días" like your frontend
  def time_ago_in_words(time)
    return "" unless time
    
    seconds = (Time.now - time).to_i
    case seconds
    when 0...60 then "Hace unos segundos"
    when 60...3600 then "Hace #{seconds / 60} minutos"
    when 3600...86400 then "Hace #{seconds / 3600} horas"
    when 86400...604800 then "Hace #{seconds / 86400} días"
    else "Hace #{seconds / 604800} semanas"
    end
  end
end