# controllers/payment_controller.rb
require 'sinatra/base'
require_relative 'application_controller'

class PaymentController < ApplicationController

  # ==========================================
  # MIDDLEWARE DE AUTENTICACIÓN
  # ==========================================
  
  # Todas las rutas de pagos requieren autenticación
  before '/api/v1/payment-methods*' do
    authenticate_user!
  end

  # ==========================================
  # CRUD DE MÉTODOS DE PAGO DEL USUARIO
  # ==========================================

  # GET /api/v1/payment-methods - Listar métodos de pago del usuario actual
  get '/api/v1/payment-methods' do
    handle_sequel_errors do
      payment_methods = UserPaymentMethod.where(user_id: current_user.id)
                                         .eager(:payment_method)
                                         .order(Sequel.desc(:is_default), Sequel.desc(:created_at))
                                         .all

      success_response(
        message: 'Listado de mis métodos de pago',
        data: {
          payment_methods: payment_methods.map { |pm| pm.safe_attributes }
        }
      )
    end
  end

  # GET /api/v1/payment-methods/:id - Obtener detalle de un método de pago específico
  get '/api/v1/payment-methods/:id' do
    handle_sequel_errors do
      payment_method = UserPaymentMethod.eager(:payment_method)[params[:id]]
      
      return not_found_response(message: 'Método de pago no encontrado') unless payment_method

      # Verificar que pertenece al usuario actual
      authorize_user!(payment_method.user_id)

      success_response(
        message: 'Detalle del método de pago',
        data: payment_method.safe_attributes
      )
    end
  end

  # POST /api/v1/payment-methods - Agregar un nuevo método de pago (tarjeta)
  post '/api/v1/payment-methods' do
    handle_sequel_errors do
      data = parse_json_body

      # Validar campos requeridos para tarjeta
      validate_required_fields(data, [
        :card_brand,
        :card_last4,
        :card_holder_name,
        :expiry_month,
        :expiry_year
      ])

      # Validar formato de card_last4 (4 dígitos)
      unless data[:card_last4].to_s.match?(/^\d{4}$/)
        return error_response(
          message: 'card_last4 debe ser 4 dígitos',
          error: 'INVALID_CARD_LAST4',
          status: 422
        )
      end

      # Validar mes (1-12)
      expiry_month = data[:expiry_month].to_i
      if expiry_month < 1 || expiry_month > 12
        return error_response(
          message: 'El mes de expiración debe estar entre 1 y 12',
          error: 'INVALID_EXPIRY_MONTH',
          status: 422
        )
      end

      # Validar año (actual o futuro)
      expiry_year = data[:expiry_year].to_i
      current_year = Time.now.year
      if expiry_year < current_year
        return error_response(
          message: 'La tarjeta está expirada',
          error: 'CARD_EXPIRED',
          status: 422
        )
      end

      # Si es el mismo año, validar que el mes sea actual o futuro
      if expiry_year == current_year && expiry_month < Time.now.month
        return error_response(
          message: 'La tarjeta está expirada',
          error: 'CARD_EXPIRED',
          status: 422
        )
      end

      # Verificar si ya existe una tarjeta con los mismos últimos 4 dígitos
      existing_card = UserPaymentMethod.where(
        user_id: current_user.id,
        card_last4: data[:card_last4].to_s,
        card_brand: data[:card_brand]
      ).first

      if existing_card
        return conflict_response(
          message: 'Ya tienes una tarjeta registrada con estos datos'
        )
      end

      # Si es la primera tarjeta, establecerla como predeterminada
      is_first_card = UserPaymentMethod.where(user_id: current_user.id).count == 0
      is_default = data[:is_default] || is_first_card

      # Si se marca como predeterminada, desmarcar las demás
      if is_default
        UserPaymentMethod.where(user_id: current_user.id)
                         .update(is_default: false)
      end

      # Obtener el payment_method_id de 'CARD' (id = 2)
      card_payment_method = PaymentMethod.where(code: 'CARD').first
      unless card_payment_method
        return server_error_response(
          error_message: 'Método de pago CARD no encontrado en la base de datos'
        )
      end

      # Crear el método de pago
      user_payment = UserPaymentMethod.create(
        user_id: current_user.id,
        payment_method_id: card_payment_method.id,
        card_brand: data[:card_brand].strip,
        card_last4: data[:card_last4].to_s,
        card_holder_name: data[:card_holder_name].strip,
        expiry_month: expiry_month,
        expiry_year: expiry_year,
        is_default: is_default
      )

      created_response(
        message: 'Tarjeta agregada exitosamente',
        data: user_payment.safe_attributes
      )
    end
  end

  # PUT /api/v1/payment-methods/:id - Actualizar un método de pago
  put '/api/v1/payment-methods/:id' do
    handle_sequel_errors do
      payment_method = UserPaymentMethod.eager(:payment_method)[params[:id]]
      
      return not_found_response(message: 'Método de pago no encontrado') unless payment_method

      # Verificar que pertenece al usuario actual
      authorize_user!(payment_method.user_id)

      data = parse_json_body

      # Validar mes si se está actualizando
      if data[:expiry_month]
        expiry_month = data[:expiry_month].to_i
        if expiry_month < 1 || expiry_month > 12
          return error_response(
            message: 'El mes de expiración debe estar entre 1 y 12',
            error: 'INVALID_EXPIRY_MONTH',
            status: 422
          )
        end
      end

      # Validar año si se está actualizando
      if data[:expiry_year]
        expiry_year = data[:expiry_year].to_i
        current_year = Time.now.year
        if expiry_year < current_year
          return error_response(
            message: 'La tarjeta está expirada',
            error: 'CARD_EXPIRED',
            status: 422
          )
        end
      end

      # Si se marca como predeterminada, desmarcar las demás
      if data[:is_default] == true
        UserPaymentMethod.where(user_id: current_user.id)
                         .exclude(id: payment_method.id)
                         .update(is_default: false)
      end

      # Actualizar solo los campos permitidos
      update_data = {}
      update_data[:card_holder_name] = data[:card_holder_name].strip if data[:card_holder_name]
      update_data[:expiry_month] = data[:expiry_month] if data[:expiry_month]
      update_data[:expiry_year] = data[:expiry_year] if data[:expiry_year]
      update_data[:is_default] = data[:is_default] if data.key?(:is_default)

      payment_method.update(update_data)

      success_response(
        message: 'Método de pago actualizado exitosamente',
        data: payment_method.safe_attributes
      )
    end
  end

  # DELETE /api/v1/payment-methods/:id - Eliminar un método de pago
  delete '/api/v1/payment-methods/:id' do
    handle_sequel_errors do
      payment_method = UserPaymentMethod[params[:id]]
      
      return not_found_response(message: 'Método de pago no encontrado') unless payment_method

      # Verificar que pertenece al usuario actual
      authorize_user!(payment_method.user_id)

      # Verificar si es el método predeterminado
      was_default = payment_method.is_default

      # Eliminar el método de pago
      payment_method.destroy

      # Si era el predeterminado, establecer otro como predeterminado
      if was_default
        other_method = UserPaymentMethod.where(user_id: current_user.id).first
        other_method.update(is_default: true) if other_method
      end

      success_response(
        message: 'Método de pago eliminado exitosamente',
        data: nil
      )
    end
  end

  # PUT /api/v1/payment-methods/:id/set-default - Establecer método como predeterminado
  put '/api/v1/payment-methods/:id/set-default' do
    handle_sequel_errors do
      payment_method = UserPaymentMethod[params[:id]]
      
      return not_found_response(message: 'Método de pago no encontrado') unless payment_method

      # Verificar que pertenece al usuario actual
      authorize_user!(payment_method.user_id)

      # Desmarcar todos los métodos como predeterminados
      UserPaymentMethod.where(user_id: current_user.id)
                       .update(is_default: false)

      # Marcar este como predeterminado
      payment_method.update(is_default: true)

      success_response(
        message: 'Método de pago establecido como predeterminado',
        data: payment_method.safe_attributes
      )
    end
  end

  # ==========================================
  # INFORMACIÓN DE CATÁLOGO (PÚBLICO)
  # ==========================================

  # GET /api/v1/payment-methods/available - Listar métodos de pago disponibles (catálogo)
  get '/api/v1/payment-methods/available' do
    handle_sequel_errors do
      methods = PaymentMethod.all

      success_response(
        message: 'Métodos de pago disponibles',
        data: {
          payment_methods: methods.map do |pm|
            {
              id: pm.id,
              code: pm.code,
              name: pm.name
            }
          end
        }
      )
    end
  end

end
