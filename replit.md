# Aplicación Web Ruby Sinatra

## Descripción
Aplicación web completa construida con Ruby Sinatra que incluye:
- ApplicationController como controlador principal
- Vistas ERB con layout responsive
- Integración con base de datos SQLite3 usando Sequel ORM
- Estructura de modelos base
- Directorio público para archivos estáticos

## Estructura del Proyecto
```
/
├── controllers/
│   └── application_controller.rb  # Controlador principal de la aplicación
├── models/
│   ├── base_model.rb             # Modelo base con Sequel
│   └── user.rb                   # Modelo de ejemplo
├── views/
│   ├── layout.erb                # Layout principal con CSS
│   └── index.erb                 # Vista de página principal
├── config/
│   └── database.rb               # Configuración de base de datos SQLite3
├── public/
│   └── images/                   # Directorio para archivos estáticos
├── db/                           # Base de datos SQLite3
├── Gemfile                       # Dependencias Ruby
├── config.ru                     # Configuración Rack
└── app.rb                        # Punto de entrada
```

## Tecnologías Utilizadas
- **Ruby 3.2** - Lenguaje de programación
- **Sinatra 3.2** - Framework web minimalista
- **Sequel 5.96** - ORM para base de datos
- **SQLite3** - Base de datos embebida
- **Puma** - Servidor web
- **ERB** - Motor de plantillas

## Estado Actual
- ✅ Entorno Ruby configurado
- ✅ Servidor Sinatra funcionando en puerto 5000
- ✅ Base de datos SQLite3 configurada
- ✅ Modelos con Sequel ORM
- ✅ Vistas ERB con layout responsive
- ✅ Directorio público para imágenes
- ✅ Estructura MVC completa

## Próximos Pasos Recomendados
1. Crear migraciones de base de datos
2. Implementar autenticación de usuarios
3. Agregar más modelos y controladores
4. Implementar formularios y validaciones
5. Agregar CSS/JavaScript personalizado
6. Configurar tests automatizados

## Comandos Útiles
- `bundle install` - Instalar dependencias
- `bundle exec rackup` - Ejecutar servidor de desarrollo
- `bundle exec sequel -m db/migrations sqlite://db/development.sqlite3` - Ejecutar migraciones (cuando se creen)

Fecha de creación: 5 de septiembre de 2025