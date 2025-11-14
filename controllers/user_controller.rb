require 'sinatra/base'
require_relative '../config/database'


class UserController < ApplicationController
  # Ruta principal
    get '/api/v1/users' do
            content_type :json

            begin
                # SELECT * FROM users;
                {
                    success: true,
                    message: "Usuarios OK",
                    data: User.all,
                    error: nil
                }.to_json
                
                rescue => e
                    status 500  # Internal Server Error
                
                    {
                        success: false,
                        message: "Error al obtener usuarios",
                        data: [],
                        error: e.message
                    }.to_json
            end
    end

    get '/api/v1/users/:id' do
            id = params[:id]
            
            begin
                # SELECT * FROM users WHERE id = :id
                # BUSCAR USUARIO
                usuario = User[id]

                if usuario
                    # Usuario Encontrado
                    {
                        success: true,
                        message: "Usuario OK",
                        data: usuario.values,
                        error: nil
                    }.to_json
                else
                    status 404  # Internal Server Error
                
                    {
                        success: false,
                        message: "Usuario NO ENCONTRADO",
                        data: nil,
                        error: "No se encontro el usuario: #{id}"
                    }.to_json
                end
                rescue => e
                    status 500  # Internal Server Error
                
                    {
                        success: false,
                        message: "Error al obtener usuario",
                        data: nil,
                        error: e.message
                    }.to_json
            end
        
    end

    post '/api/v1/adduser' do
            content_type :json
            
            begin
                request_body = JSON.parse(request.body.read, symbolize_names: true)

                
                required_fields = [:first_name, :last_name, :email, :password_hash]
                missing_fields = required_fields.select { |field| request_body[field].to_s.empty? }
                
                user = User.new(
                first_name: request_body[:first_name],
                last_name: request_body[:last_name],
                email: request_body[:email],
                password_hash: request_body[:password_hash],
                phone_number: request_body[:phone_number],
                profile_picture: request_body[:profile_picture],
                date_of_birth: request_body[:date_of_birth],
                gender: request_body[:gender],
                rating: request_body[:rating] || 0.0,
                total_ratings: request_body[:total_ratings] || 0,
                is_verified: request_body.fetch(:is_verified, false),
                is_active: request_body.fetch(:is_active, true)
                )
                
                if user.valid?
                user.save
                
                status 201 # Created
                {
                    success: true,
                    message: "User created successfully",
                    data: user.values,
                    error: nil
                }.to_json
                else
                status 422 # Unprocessable Entity
                {
                    success: false,
                    message: "Validation failed",
                    data: nil,
                    error: user.errors.full_messages.join(', ')
                }.to_json
                end

                rescue => e
                    puts e.backtrace.join("\n")
                    status 500 # Internal Server Error
                    {
                    success: false,
                    message: "Error creating user",
                    data: nil,
                    error: e.message
                    }.to_json
            end
            
    end

    put '/api/v1/edit/:id' do
        content_type :json
            
        begin
            id = params[:id]
            request_body = JSON.parse(request.body.read, symbolize_names: true)
                
            user = User[id]
                        
            # Preparar campos para actualizar
            update_fields = {}
                
            # Campos permitidos para actualizar
            allowed_fields = [
            :first_name, :last_name, :email, :password_hash, :phone_number,
            :profile_picture, :date_of_birth, :gender, :rating, :total_ratings,
            :is_verified, :is_active
            ]
                
            # Solo incluir campos que están presentes en el request
            allowed_fields.each do |field|
            if request_body.key?(field)
                update_fields[field] = request_body[field]
            end
            end
                
            # Validar que haya campos para actualizar
            if update_fields.empty?
            status 400 # Bad Request
            return {
                success: false,
                message: "No fields to update",
                data: nil,
                error: "Provide at least one field to update"
            }.to_json
            end
                
            # Verificar si el email ya existe (si se está actualizando el email)
            if update_fields[:email] && update_fields[:email] != user.email
            existing_user = User[email: update_fields[:email]]
            if existing_user && existing_user.id != user.id
                status 409 # Conflict
                return {
                success: false,
                message: "Email already exists",
                data: nil,
                error: "Email #{update_fields[:email]} is already registered to another user"
                }.to_json
            end
            end
                
            # Actualizar el usuario
            user.update(update_fields)
                
            if user.valid?
            # Recargar el usuario para obtener los datos actualizados
            user.refresh
                
            status 200 # OK
            {
                success: true,
                message: "User updated successfully",
                data: user.values,
                error: nil
            }.to_json
            else
            status 422 # Unprocessable Entity
            {
                success: false,
                message: "Validation failed",
                data: nil,
                error: user.errors.full_messages.join(', ')
            }.to_json
            end
                    
        rescue => e
            puts e.backtrace.join("\n")
            status 500 # Internal Server Error
            {
            success: false,
            message: "Error updating user",
            data: nil,
            error: e.message
            }.to_json
        end
    end

    delete '/api/v1/delete/:id' do
        content_type :json
    
        begin
            id = params[:id]
            
            # Buscar usuario
            user = User[id]
            
            unless user
            status 404 # Not Found
            return {
                success: false,
                message: "User not found",
                data: nil,
                error: "No user found with id: #{id}"
            }.to_json
            end
            
            # Eliminar el usuario
            user.delete
            
            status 200 # OK
            {
            success: true,
            message: "User deleted successfully",
            data: { id: id },
            error: nil
            }.to_json
            
        rescue => e
            puts e.backtrace.join("\n")
            status 500 # Internal Server Error
            {
            success: false,
            message: "Error deleting user",
            data: nil,
            error: e.message
            }.to_json
        end
    end

    post '/api/v1/sign-in' do
        content_type :json
        
            
            begin
                request_body = JSON.parse(request.body.read, symbolize_names: true)

                # Validar campos requeridos
                required_fields = [:email, :password_hash]
                missing_fields = required_fields.select { |field| request_body[field].to_s.empty? }

                unless missing_fields.empty?
                status 400 # Bad Request
                return {
                    success: false,
                    message: "Campo(s) incompletos",
                    data: nil,
                    error: "Missing required fields: #{missing_fields.join(', ')}"
                }.to_json
                end

                email = request_body[:email]
                password_hash = request_body[:password_hash]

                usuario = User.select(:first_name, :last_name, :email, :profile_picture, :gender,
                            :rating, :total_ratings, :is_verified, :is_active).where(email: email, password_hash: password_hash).first

                #token = generate_token(usuario)
                
                if usuario
                # Usuario encontrado y credenciales correctas
                token = generate_token({ user_id: usuario.id, email: usuario.email })
                {
                    success: true,
                    message: "Login successful",
                    data: {
                            user: usuario.attributes,
                            token: token
                            },
                    error: nil
                }.to_json
                else
                    status 401 # Unauthorized
                    {
                        success: false,
                        message: "Invalid credentials",
                        data: nil,
                        error: "Email or password incorrect"
                    }.to_json
                    end
                rescue => e
                    puts e.backtrace.join("\n")
                    status 500 # Internal Server Error
                
                    {
                        success: false,
                        message: "Error al durante el login",
                        data: nil,
                        error: e.message
                    }.to_json
            end
        
        

    end

    post '/api/v1/login' do
         content_type :json
    
    begin
      request_body = JSON.parse(request.body.read, symbolize_names: true)

      # Validar campos requeridos
      required_fields = [:email, :password_hash]
      missing_fields = required_fields.select { |field| request_body[field].to_s.empty? }

      unless missing_fields.empty?
        status 400
        return {
          success: false,
          message: "Campos incompletos",
          data: nil,
          error: "Faltan campos: #{missing_fields.join(', ')}"
        }.to_json
      end

      email = request_body[:email]&.strip
      password_hash = request_body[:password_hash]&.strip

      # Buscar usuario
      usuario = User.where(email: email, password_hash: password_hash, is_active: true).first

      if usuario
        # Generar token JWT
        token = generate_token(usuario.id, usuario.email)
        
        {
          success: true,
          message: "Login exitoso",
          data: {
            user: {
              id: usuario.id,
              first_name: usuario.first_name,
              last_name: usuario.last_name,
              email: usuario.email,
              profile_picture: usuario.profile_picture,
              gender: usuario.gender,
              rating: usuario.rating,
              total_ratings: usuario.total_ratings,
              is_verified: usuario.is_verified,
              is_active: usuario.is_active
            },
            tokens: {
                proyecto: token,
              #access_token: token,
              # token_type: "Bearer",
              # expires_in: settings.jwt_expiration
            }
          },
          error: nil
        }.to_json
      else
        status 401
        {
          success: false,
          message: "Credenciales inválidas",
          data: nil,
          error: "Email o contraseña incorrectos"
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
      puts "Error en login: #{e.message}"
      puts e.backtrace.join("\n")
      status 500
      {
        success: false,
        message: "Error en el servidor",
        data: nil,
        error: e.message
      }.to_json
    end
end
end