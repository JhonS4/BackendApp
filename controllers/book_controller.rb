require 'sinatra/base'
require 'json'
require_relative '../config/database'

class BookController < ApplicationController
  # Vista HTML (si el profe quiere ver algo en navegador)
  get '/books' do
    erb :books
  end

  # GET /api/v1/books -> listado para frontend / Postman
  get '/api/v1/books' do
    content_type :json

    begin
      books = Book.eager(:publisher, :authors, :genres).all

      books_data = books.map { |book| serialize_book(book) }

      status 200
      {
        success: true,
        message: "Listado de libros obtenido correctamente",
        data: books_data,
        error: nil
      }.to_json

    rescue => e
      status 500
      {
        success: false,
        message: "Error al obtener los libros",
        data: [],
        error: e.message
      }.to_json
    end
  end

  # GET /api/v1/books/:id -> detalle de un libro
  get '/api/v1/books/:id' do
    content_type :json

    begin
      book = Book.eager(:publisher, :authors, :genres)[id: params[:id]]

      unless book
        status 404
        return {
          success: false,
          message: "Libro no encontrado",
          data: nil,
          error: "BOOK_NOT_FOUND"
        }.to_json
      end

      status 200
      {
        success: true,
        message: "Detalle de libro",
        data: serialize_book(book),
        error: nil
      }.to_json

    rescue => e
      status 500
      {
        success: false,
        message: "Error al obtener el libro",
        data: nil,
        error: e.message
      }.to_json
    end
  end

  private

  def serialize_book(book)
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
end
