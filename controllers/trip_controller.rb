# controllers/trip_controller.rb
require 'sinatra/base'
require 'json'
require_relative 'application_controller'

class TripController < ApplicationController
  #
  # GET /api/v1/trips
  # Lista viajes usando consultas directas (sin modelo Trip)
  #
  get '/api/v1/trips' do
    content_type :json

    begin
      # Obtiene todas las filas de la tabla trips como hashes
      trips = DB[:trips].all

      data = trips.map do |t|
        # t es un Hash con claves símbolo: t[:driver_id], t[:origin_address], etc.
        driver  = DB[:users][id: t[:driver_id]]
        vehicle = DB[:vehicles][id: t[:vehicle_id]]

        {
          id:                          t[:id],
          origin_address:              t[:origin_address],
          destination_address:         t[:destination_address],
          departure_datetime:          t[:departure_datetime],
          estimated_arrival_datetime:  t[:estimated_arrival_datetime],
          available_seats:             t[:available_seats],
          # Por ahora NO calculamos remaining_seats para evitar más consultas pesadas
          remaining_seats:             nil,
          price_per_seat:              t[:price_per_seat],
          trip_status:                 t[:trip_status],
          meeting_point:               t[:meeting_point],
          notes:                       t[:notes],

          driver: driver && {
            id:            driver[:id],
            full_name:     "#{driver[:first_name]} #{driver[:last_name]}",
            rating:        driver[:rating],
            total_ratings: driver[:total_ratings]
          },

          vehicle: vehicle && {
            id:            vehicle[:id],
            make:          vehicle[:make],
            model:         vehicle[:model],
            year:          vehicle[:year],
            color:         vehicle[:color],
            license_plate: vehicle[:license_plate],
            capacity:      vehicle[:capacity]
          }
        }
      end

      {
        success: true,
        message: "Trips OK",
        data: data,
        error: nil
      }.to_json

    rescue => e
      status 500
      {
        success: false,
        message: "Error al listar viajes",
        data: [],
        error: e.message
      }.to_json
    end
  end

  #
  # POST /api/v1/trips
  # Crea un viaje (por ahora recibimos driver_id en el body)
  #
  post '/api/v1/trips' do
    content_type :json

    begin
      body = JSON.parse(request.body.read, symbolize_names: true)

      required_fields = [
        :driver_id,
        :vehicle_id,
        :origin_address,
        :destination_address,
        :departure_datetime,
        :available_seats,
        :price_per_seat
      ]

      missing = required_fields.select { |f| body[f].nil? || body[f].to_s.strip.empty? }

      unless missing.empty?
        status 400
        return {
          success: false,
          message: "Campos incompletos",
          data: nil,
          error: "Faltan campos: #{missing.join(', ')}"
        }.to_json
      end

      trip = Trip.new(
        driver_id:                  body[:driver_id],
        vehicle_id:                 body[:vehicle_id],
        origin_address:             body[:origin_address],
        origin_latitude:            body[:origin_latitude],
        origin_longitude:           body[:origin_longitude],
        destination_address:        body[:destination_address],
        destination_latitude:       body[:destination_latitude],
        destination_longitude:      body[:destination_longitude],
        departure_datetime:         body[:departure_datetime],
        estimated_arrival_datetime: body[:estimated_arrival_datetime],
        available_seats:            body[:available_seats],
        price_per_seat:             body[:price_per_seat],
        trip_status:                body[:trip_status] || 'PENDING',
        meeting_point:              body[:meeting_point],
        notes:                      body[:notes]
      )

      if trip.valid?
        trip.save

        status 201
        {
          success: true,
          message: "Trip created successfully",
          data: trip.values,
          error: nil
        }.to_json
      else
        status 422
        {
          success: false,
          message: "Validation failed",
          data: nil,
          error: (trip.errors || {}).full_messages.join(', ')
        }.to_json
      end

    rescue JSON::ParserError => e
      status 400
      {
        success: false,
        message: "JSON inválido",
        data: nil,
        error: e.message
      }.to_json

    rescue => e
      status 500
      {
        success: false,
        message: "Error al crear viaje",
        data: nil,
        error: e.message
      }.to_json
    end
  end

  #
  # POST /api/v1/trips/:id/bookings
  # Crear una reserva para un viaje
  #
  post '/api/v1/trips/:id/bookings' do
    content_type :json

    begin
      trip_id = params[:id].to_i
      trip    = Trip[trip_id]

      unless trip
        status 404
        return {
          success: false,
          message: "Trip not found",
          data: nil,
          error: "No se encontró el viaje #{trip_id}"
        }.to_json
      end

      body = JSON.parse(request.body.read, symbolize_names: true)

      required_fields = [:passenger_id, :seats_reserved]
      missing = required_fields.select { |f| body[f].nil? || body[f].to_s.strip.empty? }

      unless missing.empty?
        status 400
        return {
          success: false,
          message: "Campos incompletos",
          data: nil,
          error: "Faltan campos: #{missing.join(', ')}"
        }.to_json
      end

      seats_reserved = body[:seats_reserved].to_i
      remaining      = trip.remaining_seats

      if seats_reserved <= 0
        status 400
        return {
          success: false,
          message: "Número de asientos inválido",
          data: nil,
          error: "seats_reserved debe ser mayor que 0"
        }.to_json
      end

      if seats_reserved > remaining
        status 409
        return {
          success: false,
          message: "No hay asientos suficientes",
          data: nil,
          error: "Quedan #{remaining} asientos disponibles"
        }.to_json
      end

      total_price = seats_reserved * trip.price_per_seat

      booking = Booking.new(
        trip_id:          trip.id,
        passenger_id:     body[:passenger_id],
        seats_reserved:   seats_reserved,
        total_price:      total_price,
        booking_status:   body[:booking_status] || 'CONFIRMED',
        pickup_location:  body[:pickup_location],
        pickup_latitude:  body[:pickup_latitude],
        pickup_longitude: body[:pickup_longitude],
        special_requests: body[:special_requests]
      )

      if booking.valid?
        booking.save

        {
          success: true,
          message: "Booking created successfully",
          data: {
            booking: booking.values,
            trip_remaining_seats: trip.remaining_seats
          },
          error: nil
        }.to_json
      else
        status 422
        {
          success: false,
          message: "Validation failed",
          data: nil,
          error: (booking.errors || {}).full_messages.join(', ')
        }.to_json
      end

    rescue JSON::ParserError => e
      status 400
      {
        success: false,
        message: "JSON inválido",
        data: nil,
        error: e.message
      }.to_json

    rescue => e
      status 500
      {
        success: false,
        message: "Error al crear reserva",
        data: nil,
        error: e.message
      }.to_json
    end
  end

  #
  # GET /api/v1/trips/:id – Detalle de viaje (conductor, vehículo, reservas)
  #   👉 Versión sin modelos, solo usando DB[:tabla]
  #
  get '/api/v1/trips/:id' do
    content_type :json

    begin
      trip_id = params[:id].to_i
      t = DB[:trips][id: trip_id]

      unless t
        status 404
        return {
          success: false,
          message: "Viaje no encontrado",
          data: nil,
          error: "No existe el viaje con id #{trip_id}"
        }.to_json
      end

      driver   = DB[:users][id: t[:driver_id]]
      vehicle  = DB[:vehicles][id: t[:vehicle_id]]
      bookings = DB[:bookings].where(trip_id: trip_id).all

      trip_json = {
        id:                          t[:id],
        origin_address:              t[:origin_address],
        destination_address:         t[:destination_address],
        departure_datetime:          t[:departure_datetime],
        estimated_arrival_datetime:  t[:estimated_arrival_datetime],
        available_seats:             t[:available_seats],
        # Si quieres, más adelante calculas remaining_seats con SUM de bookings
        remaining_seats:             nil,
        price_per_seat:              t[:price_per_seat],
        trip_status:                 t[:trip_status],
        meeting_point:               t[:meeting_point],
        notes:                       t[:notes],

        driver: driver && {
          id:            driver[:id],
          full_name:     "#{driver[:first_name]} #{driver[:last_name]}",
          rating:        driver[:rating],
          total_ratings: driver[:total_ratings]
        },

        vehicle: vehicle && {
          id:            vehicle[:id],
          make:          vehicle[:make],
          model:         vehicle[:model],
          year:          vehicle[:year],
          color:         vehicle[:color],
          license_plate: vehicle[:license_plate],
          capacity:      vehicle[:capacity]
        },

        bookings: bookings.map do |b|
          passenger = DB[:users][id: b[:passenger_id]]

          {
            id:              b[:id],
            seats_reserved:  b[:seats_reserved],
            total_price:     b[:total_price],
            booking_status:  b[:booking_status],
            pickup_location: b[:pickup_location],
            special_requests: b[:special_requests],
            passenger: passenger && {
              id:            passenger[:id],
              full_name:     "#{passenger[:first_name]} #{passenger[:last_name]}",
              rating:        passenger[:rating],
              total_ratings: passenger[:total_ratings]
            }
          }
        end
      }

      {
        success: true,
        message: "Viaje obtenido correctamente",
        data: trip_json,
        error: nil
      }.to_json

    rescue => e
      status 500
      {
        success: false,
        message: "Error al obtener viaje",
        data: nil,
        error: e.message
      }.to_json
    end
  end
end
