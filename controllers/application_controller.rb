# controllers/application_controller.rb - VERSIÓN MEJORADA
require 'sinatra/base'
require 'jwt'
require 'json'
require 'rack/deflater'
require_relative '../helpers/application_helper'
require_relative '../config/database'

class ApplicationController < Sinatra::Base
  helpers ApplicationHelper
  
  # ============================================
  # CONFIGURACIÓN
  # ============================================
  configure do
    set :views, File.expand_path('../views', __dir__)
    set :public_folder, File.expand_path('../public', __dir__)
    set :bind, '0.0.0.0'
    set :port, 5000

    # JWT
    set :jwt_secret, ENV['JWT_SECRET'] || 'tu_clave_super_secreta_aqui'
    set :jwt_expiration, 24 * 60 * 60
    
    # CORS
    set :allow_origin, ENV['ALLOW_ORIGIN'] || '*'
    set :allow_methods, 'GET,POST,PUT,DELETE,OPTIONS'
    set :allow_headers, 'Content-Type,Authorization,Accept,X-Request-ID'
    
    # Rate Limiting
    set :rate_limit_requests, 100
    set :rate_limit_window, 60
    
    # Compresión
    use Rack::Deflater
  end
  
  configure :development do
    set :logging, true
    set :dump_errors, true
    set :show_exceptions, true
    DB.loggers << Logger.new($stdout)
  end

  # Cargar modelos
  Dir[File.expand_path('../models/*.rb', __dir__)].each { |file| require file }

  # ============================================
  # MIDDLEWARE
  # ============================================
  
  # Request ID
  before do
    @request_id = request.env['HTTP_X_REQUEST_ID'] || SecureRandom.uuid
    @request_start_time = Time.now
    response.headers['X-Request-ID'] = @request_id
  end
  
  # CORS
  before do
    response.headers['Access-Control-Allow-Origin'] = settings.allow_origin
    response.headers['Access-Control-Allow-Methods'] = settings.allow_methods
    response.headers['Access-Control-Allow-Headers'] = settings.allow_headers
  end

  # Logging
  before do
    logger.info "=" * 80
    logger.info "🔵 [#{@request_id}] #{request.request_method} #{request.path}"
    logger.info "📍 IP: #{request.ip}"
    logger.info "🔑 User: #{current_user&.id || 'guest'}"
  end
  
  after do
    duration = ((Time.now - @request_start_time) * 1000).round(2)
    logger.info "✅ [#{@request_id}] #{response.status} (#{duration}ms)"
    logger.info "=" * 80
  end

  options '*' do
    200
  end

  # ============================================
  # HELPERS - RESPUESTAS
  # ============================================
  
  helpers do
    def success_response(message, data = nil, status_code = 200)
      status status_code
      content_type :json
      {
        success: true,
        message: message,
        data: data,
        error: nil,
        request_id: request_id,
        timestamp: Time.now.iso8601
      }.to_json
    end

    def error_response(message, error_details = nil, status_code = 500)
      status status_code
      content_type :json
      {
        success: false,
        message: message,
        data: nil,
        error: error_details,
        request_id: request_id,
        timestamp: Time.now.iso8601
      }.to_json
    end
    
    # ============================================
    # HELPERS - JWT
    # ============================================
    
    def generate_token(user_id, email)
      payload = {
        user_id: user_id,
        email: email,
        exp: Time.now.to_i + settings.jwt_expiration
      }
      JWT.encode(payload, settings.jwt_secret, 'HS256')
    end

    def verify_token(token)
      JWT.decode(token, settings.jwt_secret, true, { algorithm: 'HS256' })[0]
    rescue
      nil
    end

    def get_token_from_header
      auth_header = request.env['HTTP_AUTHORIZATION']
      auth_header.split(' ').last if auth_header
    end

    def current_user
      token = get_token_from_header
      return nil unless token
      
      payload = verify_token(token)
      User[payload['user_id']] if payload
    end

    def authenticated?
      !current_user.nil?
    end

    def require_authentication!
      unless authenticated?
        halt 401, error_response('No autorizado', 'Token inválido o expirado', 401)
      end
    end
    
    # ============================================
    # HELPERS - VALIDACIÓN
    # ============================================
    
    def parse_json_body
      return {} if request.body.size.zero?
      
      request.body.rewind
      JSON.parse(request.body.read, symbolize_names: true)
    rescue JSON::ParserError => e
      halt 400, error_response('JSON inválido', e.message, 400)
    end
    
    def validate_required_fields!(fields)
      body = parse_json_body
      missing = fields.select { |f| body[f].to_s.strip.empty? }
      
      unless missing.empty?
        halt 400, error_response(
          'Campos requeridos faltantes',
          "Faltan: #{missing.join(', ')}",
          400
        )
      end
      
      body
    end
    
    def validate_id!(id)
      unless id.to_s.match?(/^\d+$/)
        halt 400, error_response('ID inválido', 'El ID debe ser un número', 400)
      end
      id.to_i
    end
    
    # ============================================
    # HELPERS - PAGINACIÓN
    # ============================================
    
    def paginate(dataset)
      page = (params[:page] || 1).to_i
      per_page = [(params[:per_page] || 20).to_i, 100].min
      
      page = 1 if page < 1
      per_page = 1 if per_page < 1
      
      offset = (page - 1) * per_page
      paginated = dataset.limit(per_page).offset(offset)
      total = dataset.count
      
      {
        data: paginated.all,
        pagination: {
          current_page: page,
          per_page: per_page,
          total_items: total,
          total_pages: (total.to_f / per_page).ceil,
          has_next: page < (total.to_f / per_page).ceil,
          has_prev: page > 1
        }
      }
    end
    
    def paginated_response(message, dataset)
      result = paginate(dataset)
      success_response(message, {
        items: result[:data],
        pagination: result[:pagination]
      })
    end
    
    # ============================================
    # HELPERS - UTILIDADES
    # ============================================
    
    def request_id
      @request_id
    end
    
    def log_info(message)
      logger.info "ℹ️  [#{request_id}] #{message}"
    end
    
    def log_error(message, error = nil)
      logger.error "❌ [#{request_id}] #{message}"
      logger.error "   #{error.message}" if error
    end
  end

  # ============================================
  # MANEJO DE ERRORES
  # ============================================
  
  not_found do
    if request.path.start_with?('/api/')
      error_response('Endpoint no encontrado', "La ruta #{request.path} no existe", 404)
    else
      erb :not_found rescue '<h1>404 - Página no encontrada</h1>'
    end
  end

  error do
    err = env['sinatra.error']
    log_error("Error interno", err)
    
    if request.path.start_with?('/api/')
      error_response(
        'Error interno del servidor',
        settings.development? ? err.message : 'Ocurrió un error inesperado',
        500
      )
    else
      erb :error rescue '<h1>500 - Error interno</h1>'
    end
  end

  # ============================================
  # RUTAS API
  # ============================================
  
  get '/api/v1/health' do
    success_response('API funcionando', {
      status: 'online',
      version: '1.0.0',
      database: DB.test_connection ? 'connected' : 'disconnected'
    })
  end

  get '/api/v1/info' do
    success_response('Info de la API', {
      name: 'CarpoolU API',
      version: '1.0.0',
      description: 'API REST para carpooling universitario',
      endpoints: {
        users: '/api/v1/users',
        trips: '/api/v1/trips',
        health: '/api/v1/health'
      }
    })
  end

  # ============================================
  # RUTAS WEB
  # ============================================
  
  get '/' do
    erb :index
  end

  def page_title(title = "CarpoolU")
    @page_title = title
  end

  run! if app_file == $0
end
