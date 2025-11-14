
module ApplicationHelper
  def generate_token(user_id, email)
      payload = {
        user_id: user_id,
        email: email,
        exp: Time.now.to_i + settings.jwt_expiration,
        iat: Time.now.to_i
      }
      
      JWT.encode(payload, settings.jwt_secret, 'HS256')
    end

    def decode_token(token)
      begin
        decoded = JWT.decode(token, settings.jwt_secret, true, { algorithm: 'HS256' })
        decoded[0] # Devuelve el payload
      rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
        puts "Error decodificando token: #{e.message}"
        nil
      end
    end

    def current_user
      return @current_user if defined?(@current_user)
      
      auth_header = request.env['HTTP_AUTHORIZATION']
      return nil unless auth_header
      
      token = auth_header.gsub(/^Bearer /, '')
      payload = decode_token(token)
      
      @current_user = payload ? User[payload['user_id']] : nil
    end

    def authenticated?
      !current_user.nil?
    end

    def protected!
      halt 401, { 
        success: false,
        message: "No autorizado",
        error: "Token de autenticación requerido o inválido"
      }.to_json unless authenticated?
    end

    def get_user_from_token
      protected!
      current_user
    end
end
