require 'sinatra/base'
require_relative '../config/database'

class BookController < ApplicationController
  # Ruta principal
  get '/books' do
    'books'
  end
end
