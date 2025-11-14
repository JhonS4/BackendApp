require_relative 'controllers/application_controller'
require_relative 'controllers/book_controller'
require_relative 'controllers/trip_controller'
require_relative 'controllers/user_controller'
use BookController
use TripController
use UserController
run ApplicationController
