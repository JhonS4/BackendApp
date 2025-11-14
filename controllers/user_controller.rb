require 'sinatra/base'
require_relative '../config/database'


class UserController < ApplicationController
post '/api/v1/auth/login' do
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


post '/api/v1/auth/register' do
            content_type :json
            
            begin
                # Obtener parámetros
                if request.content_type == 'application/json'
                data = JSON.parse(request.body.read)
                first_name = data['first_name']
                last_name = data['last_name']
                email = data['email']
                password_hash = data['password_hash']
                else
                first_name = params[:first_name]
                last_name = params[:last_name]
                email = params[:email]
                password_hash = params[:password_hash]
                end

                # Validar campos requeridos
                if first_name.to_s.strip.empty? || last_name.to_s.strip.empty? || 
                email.to_s.strip.empty? || password_hash.to_s.empty?
                status 400
                return { 
                    success: false,
                    message: 'Todos los campos son requeridos: first_name, last_name, email, password_hash',
                    data: nil,
                    error: "Email o contraseña incorrectos"
                    }.to_json

                end

                # Validar formato de email
                unless email.match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
                status 400
                return { 
                    success: false,
                    message: 'Escribir un correo valido',
                    data: nil,
                    error: 'Formato de email inválido' }.to_json
                end

                # Verificar si el usuario ya existe
                existing_user = User.where(email: email).first
                if existing_user
                status 409
                return { 
                    success: false,
                    message: 'Email invalido',
                    data: nil,
                    error: 'El email ya está registrado' }.to_json
                end

                # Crear el nuevo usuario
                new_user = User.new(
                first_name: first_name.strip,
                last_name: last_name.strip,
                email: email.strip.downcase,
                password_hash: password_hash,
                is_active: true,
                is_verified: false,
                rating: 0.0,
                total_ratings: 0
                )

                # Validar y guardar
                if new_user.valid?
                new_user.save
                
                status 201
                {
                    success: true,
                    message: 'Usuario registrado exitosamente',
                    data: new_user.public_attributes,
                    error: nil
                }.to_json
                else
                status 422
                {
                    success: false,
                    error: 'Error de validación',
                    data: new_user.errors,
                    error: nil
                }.to_json
                end

            rescue JSON::ParserError
                status 400
                { 
                    success: false,
                    message: "JSON inválido",
                    data: nil,    
                    error: 'Formato JSON inválido' }.to_json
            rescue => e
                status 500
                { 
                    success: false,
                    message: "ERROR inesperado",
                    data: nil,    
                    error: "Error interno del servidor: #{e.message}" }.to_json
            end
            end

post '/api/v1/auth/forgot-password' do
         content_type :json
        begin
            request_body = JSON.parse(request.body.read, symbolize_names: true)
            email = request_body[:email]&.strip
            if email.to_s.strip.empty?
            status 400
            return {
                success: false,
                message: "Campo incompleto",
                data: nil,
                error: "El campo email es requerido"
            }.to_json
            end
            existing_user = User.where(email: email).first
                if existing_user
                return { 
                    success: true,
                    message: 'Se envio mensaje al email',
                    data: nil,
                    error: nil }.to_json
                else
                    { 
                    success: false,
                    message: 'Este correo no esta registrado',
                    data: nil,
                    error: 'ERROR en el correo' }.to_json
                end
            rescue => e
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
