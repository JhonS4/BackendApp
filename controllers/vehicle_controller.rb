# controllers/vehicle_controller.rb
require 'sinatra/base'
require_relative 'application_controller'

class VehicleController < ApplicationController

  # ==========================================
  # MIDDLEWARE DE AUTENTICACIÓN
  # ==========================================
  
  # Todas las rutas de vehículos requieren autenticación
  before '/api/v1/vehicles*' do
    authenticate_user!
  end

  # ==========================================
  # CRUD DE VEHÍCULOS
  # ==========================================

  # GET /api/v1/vehicles - Listar vehículos del usuario actual
  get '/api/v1/vehicles' do
    handle_sequel_errors do
      vehicles = Vehicle.where(user_id: current_user.id)
                        .order(Sequel.desc(:created_at))
                        .all

      success_response(
        message: 'Listado de mis vehículos',
        data: {
          vehicles: vehicles.map { |v| serialize_vehicle(v) }
        }
      )
    end
  end

  # GET /api/v1/vehicles/:id - Obtener detalle de un vehículo específico
  get '/api/v1/vehicles/:id' do
    handle_sequel_errors do
      vehicle = Vehicle[params[:id]]
      
      return not_found_response(message: 'Vehículo no encontrado') unless vehicle

      # Verificar que el vehículo pertenece al usuario actual
      authorize_user!(vehicle.user_id)

      success_response(
        message: 'Detalle del vehículo',
        data: serialize_vehicle(vehicle)
      )
    end
  end

  # POST /api/v1/vehicles - Agregar un nuevo vehículo
  post '/api/v1/vehicles' do
    handle_sequel_errors do
      data = parse_json_body

      # Validar campos requeridos
      validate_required_fields(data, [
        :make,
        :model,
        :year,
        :color,
        :license_plate,
        :capacity
      ])

      # Validar capacidad (debe ser entre 1 y 8)
      capacity = data[:capacity].to_i
      if capacity < 1 || capacity > 8
        return error_response(
          message: 'La capacidad debe estar entre 1 y 8 pasajeros',
          error: 'INVALID_CAPACITY',
          status: 422
        )
      end

      # Validar año (debe ser 1990 o posterior, y no mayor al año actual + 1)
      year = data[:year].to_i
      current_year = Time.now.year
      if year < 1990 || year > current_year + 1
        return error_response(
          message: "El año debe estar entre 1990 y #{current_year + 1}",
          error: 'INVALID_YEAR',
          status: 422
        )
      end

      # Validar que la placa no esté duplicada
      existing_plate = Vehicle.where(
        license_plate: data[:license_plate].strip.upcase
      ).first

      if existing_plate
        return conflict_response(
          message: 'Esta placa ya está registrada'
        )
      end

      # Crear vehículo
      vehicle = Vehicle.create(
        user_id: current_user.id,
        make: data[:make].strip,
        model: data[:model].strip,
        year: year,
        color: data[:color].strip,
        license_plate: data[:license_plate].strip.upcase,
        capacity: capacity,
        insurance_verified: data[:insurance_verified] || false,
        vehicle_picture: data[:vehicle_picture]
      )

      # Convertir al usuario en conductor si aún no lo es
      unless current_user.is_driver
        current_user.update(is_driver: true)
      end

      created_response(
        message: 'Vehículo agregado exitosamente',
        data: serialize_vehicle(vehicle)
      )
    end
  end

  # PUT /api/v1/vehicles/:id - Actualizar un vehículo existente
  put '/api/v1/vehicles/:id' do
    handle_sequel_errors do
      vehicle = Vehicle[params[:id]]
      
      return not_found_response(message: 'Vehículo no encontrado') unless vehicle

      # Verificar que el vehículo pertenece al usuario actual
      authorize_user!(vehicle.user_id)

      data = parse_json_body

      # Validar capacidad si se está actualizando
      if data[:capacity]
        capacity = data[:capacity].to_i
        if capacity < 1 || capacity > 8
          return error_response(
            message: 'La capacidad debe estar entre 1 y 8 pasajeros',
            error: 'INVALID_CAPACITY',
            status: 422
          )
        end
      end

      # Validar año si se está actualizando
      if data[:year]
        year = data[:year].to_i
        current_year = Time.now.year
        if year < 1990 || year > current_year + 1
          return error_response(
            message: "El año debe estar entre 1990 y #{current_year + 1}",
            error: 'INVALID_YEAR',
            status: 422
          )
        end
      end

      # Validar placa duplicada si se está actualizando
      if data[:license_plate]
        existing_plate = Vehicle.where(
          license_plate: data[:license_plate].strip.upcase
        ).exclude(id: vehicle.id).first

        if existing_plate
          return conflict_response(message: 'Esta placa ya está registrada')
        end
      end

      # Actualizar solo los campos proporcionados
      update_data = {}
      update_data[:make] = data[:make].strip if data[:make]
      update_data[:model] = data[:model].strip if data[:model]
      update_data[:year] = data[:year] if data[:year]
      update_data[:color] = data[:color].strip if data[:color]
      update_data[:license_plate] = data[:license_plate].strip.upcase if data[:license_plate]
      update_data[:capacity] = data[:capacity] if data[:capacity]
      update_data[:insurance_verified] = data[:insurance_verified] if data.key?(:insurance_verified)
      update_data[:vehicle_picture] = data[:vehicle_picture] if data[:vehicle_picture]

      vehicle.update(update_data)

      success_response(
        message: 'Vehículo actualizado exitosamente',
        data: serialize_vehicle(vehicle)
      )
    end
  end

  # DELETE /api/v1/vehicles/:id - Eliminar un vehículo
  delete '/api/v1/vehicles/:id' do
    handle_sequel_errors do
      vehicle = Vehicle[params[:id]]
      
      return not_found_response(message: 'Vehículo no encontrado') unless vehicle

      # Verificar que el vehículo pertenece al usuario actual
      authorize_user!(vehicle.user_id)

      # Verificar que no tenga viajes pendientes o en progreso
      pending_trips = Trip.where(
        vehicle_id: vehicle.id,
        trip_status: ['PENDING', 'IN_PROGRESS']
      ).count

      if pending_trips > 0
        return error_response(
          message: 'No puedes eliminar un vehículo con viajes pendientes o en progreso',
          error: 'VEHICLE_HAS_ACTIVE_TRIPS',
          status: 422
        )
      end

      # Eliminar el vehículo
      vehicle.destroy

      success_response(
        message: 'Vehículo eliminado exitosamente',
        data: nil
      )
    end
  end

  # ==========================================
  # MÉTODOS PRIVADOS / SERIALIZACIÓN
  # ==========================================

  private

  def serialize_vehicle(vehicle)
    {
      id: vehicle.id,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      color: vehicle.color,
      license_plate: vehicle.license_plate,
      capacity: vehicle.capacity,
      insurance_verified: vehicle.insurance_verified,
      vehicle_picture: vehicle.vehicle_picture,
      full_name: "#{vehicle.make} #{vehicle.model} #{vehicle.year}",
      created_at: vehicle.created_at
    }
  end

end
