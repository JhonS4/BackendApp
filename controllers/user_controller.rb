# controllers/user_controller.rb
require 'sinatra/base'
require 'json'
require_relative 'application_controller'

class UserController < ApplicationController
  
  # ============================================
  # PERFIL DE USUARIO
  # ============================================
  
  # GET /api/v1/users/profile
  # Obtener perfil del usuario autenticado
  get '/api/v1/users/profile' do
    require_authentication!
    
    begin
      user_data = current_user.public_attributes
      success_response('Perfil obtenido correctamente', user_data)
    rescue => e
      log_error('Error al obtener perfil', e)
      error_response('Error al obtener perfil', e.message, 500)
    end
  end
  
  # PUT /api/v1/users/profile
  # Actualizar perfil del usuario autenticado
  put '/api/v1/users/profile' do
    require_authentication!
    
    begin
      body = parse_json_body
      user = current_user
      
      # Campos actualizables
      updatable_fields = {
        first_name: body[:first_name],
        last_name: body[:last_name],
        phone_number: body[:phone_number],
        profile_picture: body[:profile_picture],
        gender: body[:gender],
        bio: body[:bio]
      }
      
      # Eliminar campos nil o vacíos
      updatable_fields.delete_if { |k, v| v.nil? || v.to_s.strip.empty? }
      
      # Si se intenta actualizar email, validar que sea único
      if body[:email] && body[:email] != user.email
        if User.where(email: body[:email]).exclude(id: user.id).count > 0
          return error_response(
            'Email ya existe',
            'El email ya está registrado por otro usuario',
            409
          )
        end
        updatable_fields[:email] = body[:email]
      end
      
      # Actualizar usuario
      user.update(updatable_fields)
      
      if user.valid?
        success_response('Perfil actualizado correctamente', user.public_attributes)
      else
        error_response(
          'Error de validación',
          user.errors.full_messages.join(', '),
          422
        )
      end
      
    rescue => e
      log_error('Error al actualizar perfil', e)
      error_response('Error al actualizar perfil', e.message, 500)
    end
  end
  
  # ============================================
  # MÉTODOS DE PAGO
  # ============================================
  
  # GET /api/v1/users/payment-methods
  # Listar métodos de pago del usuario autenticado
  get '/api/v1/users/payment-methods' do
    require_authentication!
    
    begin
      payment_methods = DB[:user_payment_methods]
        .join(:payment_methods, id: :payment_method_id)
        .where(user_id: current_user.id, 'user_payment_methods__is_active': true)
        .select(
          Sequel[:user_payment_methods][:id],
          Sequel[:payment_methods][:code].as(:payment_type),
          Sequel[:payment_methods][:name].as(:payment_name),
          Sequel[:user_payment_methods][:card_brand],
          Sequel[:user_payment_methods][:card_last4],
          Sequel[:user_payment_methods][:card_holder_name],
          Sequel[:user_payment_methods][:expiry_month],
          Sequel[:user_payment_methods][:expiry_year],
          Sequel[:user_payment_methods][:is_default]
        )
        .all
      
      methods_data = payment_methods.map do |pm|
        {
          id: pm[:id],
          payment_type: pm[:payment_type],
          payment_name: pm[:payment_name],
          card_brand: pm[:card_brand],
          card_last4: pm[:card_last4],
          card_holder_name: pm[:card_holder_name],
          expiry_month: pm[:expiry_month],
          expiry_year: pm[:expiry_year],
          is_default: pm[:is_default] == 1
        }
      end
      
      success_response('Métodos de pago obtenidos', methods_data)
      
    rescue => e
      log_error('Error al obtener métodos de pago', e)
      error_response('Error al obtener métodos de pago', e.message, 500)
    end
  end
  
  # POST /api/v1/users/payment-methods
  # Agregar nuevo método de pago
  post '/api/v1/users/payment-methods' do
    require_authentication!
    
    begin
      body = validate_required_fields!([
        :payment_method_code,
        :card_brand,
        :card_last4,
        :card_holder_name,
        :expiry_month,
        :expiry_year
      ])
      
      # Validar que el código de método de pago exista
      payment_method = DB[:payment_methods].where(code: body[:payment_method_code]).first
      
      unless payment_method
        return error_response(
          'Método de pago inválido',
          'El código de método de pago no existe',
          400
        )
      end
      
      # Validar fecha de expiración
      current_year = Time.now.year
      current_month = Time.now.month
      
      if body[:expiry_year].to_i < current_year || 
         (body[:expiry_year].to_i == current_year && body[:expiry_month].to_i < current_month)
        return error_response(
          'Tarjeta expirada',
          'La fecha de expiración debe ser futura',
          400
        )
      end
      
      # Si es_default, desmarcar otros métodos de pago
      is_default = body[:is_default] == true || body[:is_default] == 1
      
      DB.transaction do
        if is_default
          DB[:user_payment_methods]
            .where(user_id: current_user.id)
            .update(is_default: false)
        end
        
        # Insertar nuevo método de pago
        payment_method_id = DB[:user_payment_methods].insert(
          user_id: current_user.id,
          payment_method_id: payment_method[:id],
          card_brand: body[:card_brand],
          card_last4: body[:card_last4],
          card_holder_name: body[:card_holder_name],
          expiry_month: body[:expiry_month],
          expiry_year: body[:expiry_year],
          is_default: is_default,
          is_active: true
        )
        
        # Obtener el método de pago creado
        new_method = DB[:user_payment_methods]
          .join(:payment_methods, id: :payment_method_id)
          .where(Sequel[:user_payment_methods][:id] => payment_method_id)
          .select(
            Sequel[:user_payment_methods][:id],
            Sequel[:payment_methods][:code].as(:payment_type),
            Sequel[:payment_methods][:name].as(:payment_name),
            Sequel[:user_payment_methods][:card_brand],
            Sequel[:user_payment_methods][:card_last4],
            Sequel[:user_payment_methods][:card_holder_name],
            Sequel[:user_payment_methods][:expiry_month],
            Sequel[:user_payment_methods][:expiry_year],
            Sequel[:user_payment_methods][:is_default]
          )
          .first
        
        success_response(
          'Método de pago agregado correctamente',
          {
            id: new_method[:id],
            payment_type: new_method[:payment_type],
            payment_name: new_method[:payment_name],
            card_brand: new_method[:card_brand],
            card_last4: new_method[:card_last4],
            card_holder_name: new_method[:card_holder_name],
            expiry_month: new_method[:expiry_month],
            expiry_year: new_method[:expiry_year],
            is_default: new_method[:is_default] == 1
          },
          201
        )
      end
      
    rescue => e
      log_error('Error al agregar método de pago', e)
      error_response('Error al agregar método de pago', e.message, 500)
    end
  end
  
  # PUT /api/v1/users/payment-methods/:id
  # Actualizar método de pago
  put '/api/v1/users/payment-methods/:id' do
    require_authentication!
    
    begin
      method_id = validate_id!(params[:id])
      body = parse_json_body
      
      # Verificar que el método de pago pertenezca al usuario
      payment_method = DB[:user_payment_methods]
        .where(id: method_id, user_id: current_user.id)
        .first
      
      unless payment_method
        return error_response(
          'Método de pago no encontrado',
          'El método de pago no existe o no te pertenece',
          404
        )
      end
      
      # Campos actualizables
      updatable_fields = {}
      
      # Actualizar campos si vienen en el body
      updatable_fields[:card_holder_name] = body[:card_holder_name] if body[:card_holder_name]
      updatable_fields[:expiry_month] = body[:expiry_month] if body[:expiry_month]
      updatable_fields[:expiry_year] = body[:expiry_year] if body[:expiry_year]
      
      # Validar fecha de expiración si viene
      if body[:expiry_month] || body[:expiry_year]
        month = (body[:expiry_month] || payment_method[:expiry_month]).to_i
        year = (body[:expiry_year] || payment_method[:expiry_year]).to_i
        
        current_year = Time.now.year
        current_month = Time.now.month
        
        if year < current_year || (year == current_year && month < current_month)
          return error_response(
            'Tarjeta expirada',
            'La fecha de expiración debe ser futura',
            400
          )
        end
      end
      
      DB.transaction do
        # Si se marca como default, desmarcar otros
        if body[:is_default] == true || body[:is_default] == 1
          DB[:user_payment_methods]
            .where(user_id: current_user.id)
            .exclude(id: method_id)
            .update(is_default: false)
          
          updatable_fields[:is_default] = true
        end
        
        # Actualizar
        if updatable_fields.any?
          DB[:user_payment_methods]
            .where(id: method_id)
            .update(updatable_fields)
        end
        
        # Obtener método actualizado
        updated_method = DB[:user_payment_methods]
          .join(:payment_methods, id: :payment_method_id)
          .where(Sequel[:user_payment_methods][:id] => method_id)
          .select(
            Sequel[:user_payment_methods][:id],
            Sequel[:payment_methods][:code].as(:payment_type),
            Sequel[:payment_methods][:name].as(:payment_name),
            Sequel[:user_payment_methods][:card_brand],
            Sequel[:user_payment_methods][:card_last4],
            Sequel[:user_payment_methods][:card_holder_name],
            Sequel[:user_payment_methods][:expiry_month],
            Sequel[:user_payment_methods][:expiry_year],
            Sequel[:user_payment_methods][:is_default]
          )
          .first
        
        success_response(
          'Método de pago actualizado correctamente',
          {
            id: updated_method[:id],
            payment_type: updated_method[:payment_type],
            payment_name: updated_method[:payment_name],
            card_brand: updated_method[:card_brand],
            card_last4: updated_method[:card_last4],
            card_holder_name: updated_method[:card_holder_name],
            expiry_month: updated_method[:expiry_month],
            expiry_year: updated_method[:expiry_year],
            is_default: updated_method[:is_default] == 1
          }
        )
      end
      
    rescue => e
      log_error('Error al actualizar método de pago', e)
      error_response('Error al actualizar método de pago', e.message, 500)
    end
  end
  
  # DELETE /api/v1/users/payment-methods/:id
  # Eliminar método de pago (soft delete)
  delete '/api/v1/users/payment-methods/:id' do
    require_authentication!
    
    begin
      method_id = validate_id!(params[:id])
      
      # Verificar que el método de pago pertenezca al usuario
      payment_method = DB[:user_payment_methods]
        .where(id: method_id, user_id: current_user.id, is_active: true)
        .first
      
      unless payment_method
        return error_response(
          'Método de pago no encontrado',
          'El método de pago no existe o no te pertenece',
          404
        )
      end
      
      # Soft delete
      DB[:user_payment_methods]
        .where(id: method_id)
        .update(is_active: false)
      
      success_response('Método de pago eliminado correctamente')
      
    rescue => e
      log_error('Error al eliminar método de pago', e)
      error_response('Error al eliminar método de pago', e.message, 500)
    end
  end
  
  # ============================================
  # VEHÍCULOS
  # ============================================
  
  # GET /api/v1/users/vehicles
  # Listar vehículos del usuario autenticado
  get '/api/v1/users/vehicles' do
    require_authentication!
    
    begin
      vehicles = DB[:vehicles]
        .where(user_id: current_user.id, is_active: true)
        .all
      
      vehicles_data = vehicles.map do |v|
        {
          id: v[:id],
          make: v[:make],
          model: v[:model],
          year: v[:year],
          color: v[:color],
          license_plate: v[:license_plate],
          capacity: v[:capacity],
          vehicle_photo: v[:vehicle_photo],
          insurance_verified: v[:insurance_verified] == 1,
          is_default: v[:is_default] == 1
        }
      end
      
      success_response('Vehículos obtenidos correctamente', vehicles_data)
      
    rescue => e
      log_error('Error al obtener vehículos', e)
      error_response('Error al obtener vehículos', e.message, 500)
    end
  end
  
  # POST /api/v1/users/vehicles
  # Agregar nuevo vehículo
  post '/api/v1/users/vehicles' do
    require_authentication!
    
    begin
      body = validate_required_fields!([
        :make,
        :model,
        :year,
        :color,
        :license_plate,
        :capacity
      ])
      
      # Validar que el año sea razonable
      current_year = Time.now.year
      if body[:year].to_i < 1900 || body[:year].to_i > current_year + 1
        return error_response(
          'Año inválido',
          "El año debe estar entre 1900 y #{current_year + 1}",
          400
        )
      end
      
      # Validar capacidad
      if body[:capacity].to_i < 1 || body[:capacity].to_i > 8
        return error_response(
          'Capacidad inválida',
          'La capacidad debe estar entre 1 y 8 pasajeros',
          400
        )
      end
      
      # Validar que la placa no esté registrada
      existing_plate = DB[:vehicles]
        .where(license_plate: body[:license_plate], is_active: true)
        .exclude(user_id: current_user.id)
        .first
      
      if existing_plate
        return error_response(
          'Placa ya registrada',
          'Ya existe un vehículo con esta placa',
          409
        )
      end
      
      # Si es_default, desmarcar otros vehículos
      is_default = body[:is_default] == true || body[:is_default] == 1
      
      DB.transaction do
        if is_default
          DB[:vehicles]
            .where(user_id: current_user.id)
            .update(is_default: false)
        end
        
        # Insertar vehículo
        vehicle_id = DB[:vehicles].insert(
          user_id: current_user.id,
          make: body[:make],
          model: body[:model],
          year: body[:year],
          color: body[:color],
          license_plate: body[:license_plate],
          capacity: body[:capacity],
          vehicle_photo: body[:vehicle_photo],
          insurance_verified: body[:insurance_verified] || false,
          is_default: is_default,
          is_active: true
        )
        
        # Actualizar usuario como conductor si no lo es
        unless current_user.is_driver
          DB[:users]
            .where(id: current_user.id)
            .update(is_driver: true)
        end
        
        # Obtener vehículo creado
        new_vehicle = DB[:vehicles].where(id: vehicle_id).first
        
        success_response(
          'Vehículo agregado correctamente',
          {
            id: new_vehicle[:id],
            make: new_vehicle[:make],
            model: new_vehicle[:model],
            year: new_vehicle[:year],
            color: new_vehicle[:color],
            license_plate: new_vehicle[:license_plate],
            capacity: new_vehicle[:capacity],
            vehicle_photo: new_vehicle[:vehicle_photo],
            insurance_verified: new_vehicle[:insurance_verified] == 1,
            is_default: new_vehicle[:is_default] == 1
          },
          201
        )
      end
      
    rescue => e
      log_error('Error al agregar vehículo', e)
      error_response('Error al agregar vehículo', e.message, 500)
    end
  end
  
  # PUT /api/v1/users/vehicles/:id
  # Actualizar vehículo
  put '/api/v1/users/vehicles/:id' do
    require_authentication!
    
    begin
      vehicle_id = validate_id!(params[:id])
      body = parse_json_body
      
      # Verificar que el vehículo pertenezca al usuario
      vehicle = DB[:vehicles]
        .where(id: vehicle_id, user_id: current_user.id, is_active: true)
        .first
      
      unless vehicle
        return error_response(
          'Vehículo no encontrado',
          'El vehículo no existe o no te pertenece',
          404
        )
      end
      
      # Campos actualizables
      updatable_fields = {}
      
      updatable_fields[:make] = body[:make] if body[:make]
      updatable_fields[:model] = body[:model] if body[:model]
      updatable_fields[:year] = body[:year] if body[:year]
      updatable_fields[:color] = body[:color] if body[:color]
      updatable_fields[:license_plate] = body[:license_plate] if body[:license_plate]
      updatable_fields[:capacity] = body[:capacity] if body[:capacity]
      updatable_fields[:vehicle_photo] = body[:vehicle_photo] if body[:vehicle_photo]
      
      # Validar año si viene
      if body[:year]
        current_year = Time.now.year
        if body[:year].to_i < 1900 || body[:year].to_i > current_year + 1
          return error_response(
            'Año inválido',
            "El año debe estar entre 1900 y #{current_year + 1}",
            400
          )
        end
      end
      
      # Validar capacidad si viene
      if body[:capacity] && (body[:capacity].to_i < 1 || body[:capacity].to_i > 8)
        return error_response(
          'Capacidad inválida',
          'La capacidad debe estar entre 1 y 8 pasajeros',
          400
        )
      end
      
      # Validar placa única si viene
      if body[:license_plate] && body[:license_plate] != vehicle[:license_plate]
        existing_plate = DB[:vehicles]
          .where(license_plate: body[:license_plate], is_active: true)
          .exclude(id: vehicle_id)
          .first
        
        if existing_plate
          return error_response(
            'Placa ya registrada',
            'Ya existe otro vehículo con esta placa',
            409
          )
        end
      end
      
      DB.transaction do
        # Si se marca como default, desmarcar otros
        if body[:is_default] == true || body[:is_default] == 1
          DB[:vehicles]
            .where(user_id: current_user.id)
            .exclude(id: vehicle_id)
            .update(is_default: false)
          
          updatable_fields[:is_default] = true
        end
        
        # Actualizar
        if updatable_fields.any?
          DB[:vehicles]
            .where(id: vehicle_id)
            .update(updatable_fields)
        end
        
        # Obtener vehículo actualizado
        updated_vehicle = DB[:vehicles].where(id: vehicle_id).first
        
        success_response(
          'Vehículo actualizado correctamente',
          {
            id: updated_vehicle[:id],
            make: updated_vehicle[:make],
            model: updated_vehicle[:model],
            year: updated_vehicle[:year],
            color: updated_vehicle[:color],
            license_plate: updated_vehicle[:license_plate],
            capacity: updated_vehicle[:capacity],
            vehicle_photo: updated_vehicle[:vehicle_photo],
            insurance_verified: updated_vehicle[:insurance_verified] == 1,
            is_default: updated_vehicle[:is_default] == 1
          }
        )
      end
      
    rescue => e
      log_error('Error al actualizar vehículo', e)
      error_response('Error al actualizar vehículo', e.message, 500)
    end
  end
  
  # DELETE /api/v1/users/vehicles/:id
  # Eliminar vehículo (soft delete)
  delete '/api/v1/users/vehicles/:id' do
    require_authentication!
    
    begin
      vehicle_id = validate_id!(params[:id])
      
      # Verificar que el vehículo pertenezca al usuario
      vehicle = DB[:vehicles]
        .where(id: vehicle_id, user_id: current_user.id, is_active: true)
        .first
      
      unless vehicle
        return error_response(
          'Vehículo no encontrado',
          'El vehículo no existe o no te pertenece',
          404
        )
      end
      
      # Verificar que no tenga viajes pendientes o en curso
      active_trips = DB[:trips]
        .where(vehicle_id: vehicle_id)
        .where(trip_status: ['PENDING', 'IN_PROGRESS'])
        .count
      
      if active_trips > 0
        return error_response(
          'No se puede eliminar',
          'El vehículo tiene viajes pendientes o en curso',
          409
        )
      end
      
      # Soft delete
      DB[:vehicles]
        .where(id: vehicle_id)
        .update(is_active: false)
      
      success_response('Vehículo eliminado correctamente')
      
    rescue => e
      log_error('Error al eliminar vehículo', e)
      error_response('Error al eliminar vehículo', e.message, 500)
    end
  end
  
  # ============================================
  # ENDPOINTS DE AUTENTICACIÓN
  # ============================================
  
  # POST /api/v1/users/register
  # Registro de nuevo usuario
  post '/api/v1/users/register' do
    begin
      body = validate_required_fields!([
        :first_name,
        :last_name,
        :email,
        :password
      ])
      
      # Verificar que el email no exista
      if User.where(email: body[:email]).count > 0
        return error_response(
          'Email ya registrado',
          'Ya existe una cuenta con este email',
          409
        )
      end
      
      # Crear usuario
      user = User.new(
        first_name: body[:first_name],
        last_name: body[:last_name],
        email: body[:email],
        password_hash: body[:password], # En producción deberías hashear esto
        phone_number: body[:phone_number],
        gender: body[:gender],
        is_verified: false,
        is_active: true,
        is_driver: false
      )
      
      if user.valid?
        user.save
        
        # Generar token
        token = generate_token(user.id, user.email)
        
        success_response(
          'Usuario registrado correctamente',
          {
            user: user.public_attributes,
            token: token
          },
          201
        )
      else
        error_response(
          'Error de validación',
          user.errors.full_messages.join(', '),
          422
        )
      end
      
    rescue => e
      log_error('Error al registrar usuario', e)
      error_response('Error al registrar usuario', e.message, 500)
    end
  end
  
  # POST /api/v1/users/login
  # Inicio de sesión
  post '/api/v1/users/login' do
    begin
      body = validate_required_fields!([:email, :password])
      
      user = User.find_by_credentials(body[:email], body[:password])
      
      unless user
        return error_response(
          'Credenciales inválidas',
          'Email o contraseña incorrectos',
          401
        )
      end
      
      # Generar token
      token = generate_token(user.id, user.email)
      
      success_response(
        'Inicio de sesión exitoso',
        {
          user: user.public_attributes,
          token: token
        }
      )
      
    rescue => e
      log_error('Error al iniciar sesión', e)
      error_response('Error al iniciar sesión', e.message, 500)
    end
  end
  
end
