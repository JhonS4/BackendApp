require 'sinatra/base'
require_relative '../config/database'

class BookController < ApplicationController
  # Ruta principal
  get '/books' do
    erb :books
  end

  get '/api/v1/books' do
    content_type :json
    
    begin
      books = Book.eager(:publisher, :authors, :genres).all
      
      books_data = books.map do |book|
        {
          id: book.id,
          title: book.title,
          isbn: book.isbn,
          pages: book.pages,
          publication_year: book.publication_year,
          edition_year: book.edition_year,
          synopsis: book.synopsis,
          cover_image: book.cover_image,
          pdf: book.pdf,
          publisher: book.publisher&.to_hash,
          authors: book.authors.map(&:to_hash),
          genres: book.genres.map(&:to_hash)
        }
      end
      
      {
        success: true,
        message: "Listado de libros",
        data: books_data,
        error: nil
      }.to_json
      
    rescue => e
      status 500  # Internal Server Error
      
      {
        success: false,
        message: "Error al obtener los libros",
        data: [],
        error: e.message
      }.to_json
    end
  end
end
