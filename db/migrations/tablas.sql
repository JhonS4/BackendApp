---------------------------------------------------
-- MÉTODOS DE PAGO (CATÁLOGO)
---------------------------------------------------
INSERT INTO payment_methods (code, name) VALUES
  ('CASH', 'Efectivo'),
  ('CARD', 'Tarjeta');

---------------------------------------------------
-- USUARIOS (1 conductor, 1 pasajero)
---------------------------------------------------
INSERT INTO users (
  first_name, last_name, email, password_hash,
  phone_number, sex, is_verified, is_active, is_driver
) VALUES
  ('Lucía', 'Martínez', 'lucia.conductora@uni.edu', 'hash_contra_123',
   '+51 999111222', 'F', 1, 1, 1), -- CONDUCTORA
  ('Carlos', 'Pérez', 'carlos.pasajero@uni.edu', 'hash_contra_456',
   '+51 988777666', 'M', 1, 1, 0); -- PASAJERO

---------------------------------------------------
-- CONFIGURACIÓN DE USUARIO
---------------------------------------------------
INSERT INTO user_settings (user_id, notifications_enabled, dark_mode_enabled)
VALUES
  (1, 1, 0), -- Lucía
  (2, 1, 1); -- Carlos

---------------------------------------------------
-- VEHÍCULO DE LA CONDUCTORA (Lucía = user_id 1)
---------------------------------------------------
INSERT INTO vehicles (
  user_id, make, model, year, color,
  license_plate, capacity, insurance_verified
) VALUES
  (1, 'Toyota', 'Yaris', 2019, 'Rojo',
   'ABC-123', 4, 1);

---------------------------------------------------
-- VIAJE CREADO POR LA CONDUCTORA
---------------------------------------------------
INSERT INTO trips (
  driver_id, vehicle_id,
  origin_address, origin_latitude, origin_longitude,
  destination_address, destination_latitude, destination_longitude,
  departure_datetime, estimated_arrival_datetime,
  available_seats, price_per_seat,
  trip_status, meeting_point, notes
) VALUES
  (1, 1,
   'Universidad - Puerta Principal', -12.056, -77.084,
   'Centro Comercial Real Plaza', -12.060, -77.045,
   '2025-11-20 08:00', '2025-11-20 08:40',
   3, 7.50,
   'PENDING', 'Frente a la caseta de seguridad', 'Viaje de prueba CarpoolU');

---------------------------------------------------
-- RESERVA HECHA POR CARLOS (pasajero user_id = 2)
---------------------------------------------------
INSERT INTO bookings (
  trip_id, passenger_id,
  seats_reserved, total_price,
  booking_status, pickup_location
) VALUES
  (1, 2,
   1, 7.50,
   'CONFIRMED', 'Paradero Óvalo Universitario');

---------------------------------------------------
-- MÉTODO DE PAGO GUARDADO PARA CARLOS (TARJETA)
---------------------------------------------------
-- Primero buscamos el id de payment_methods = 'CARD'
-- (si quieres puedes consultar con: SELECT * FROM payment_methods;)
INSERT INTO user_payment_methods (
  user_id, payment_method_id,
  card_brand, card_last4, card_holder_name,
  expiry_month, expiry_year, is_default
) VALUES
  (2, 2,  -- user_id=2 (Carlos), payment_method_id=2 (CARD)
   'Visa', '1111', 'Carlos Pérez',
   12, 2027, 1);

---------------------------------------------------
-- PAGO DE LA RESERVA (booking_id = 1)
---------------------------------------------------
INSERT INTO payments (
  booking_id, user_payment_method_id,
  amount, payment_status, transaction_id, payment_date
) VALUES
  (1, 1,
   7.50, 'PAID', 'TXN-DEMO-0001', '2025-11-15 10:00');

---------------------------------------------------
-- RESEÑA (Carlos califica a Lucía)
---------------------------------------------------
INSERT INTO reviews (
  reviewer_id, reviewed_user_id,
  trip_id, rating, comment, is_anonymous
) VALUES
  (2, 1,
   1, 5, 'Muy buen viaje, puntual y amable.', 0);

---------------------------------------------------
-- REPORTE (ejemplo, sin usar en la app todavía)
---------------------------------------------------
INSERT INTO reports (
  reporter_id, reported_user_id, trip_id,
  problem_type, description, status
) VALUES
  (2, 1, 1,
   'CONDUCTOR', 'Solo ejemplo de reporte para pruebas.', 'PENDING');

---------------------------------------------------
-- MENSAJE EN EL CHAT (Carlos → Lucía)
---------------------------------------------------
INSERT INTO messages (
  trip_id, sender_id, receiver_id,
  message_text, is_read
) VALUES
  (1, 2, 1,
   'Hola, estaré 5 minutos antes en el punto de encuentro 😊', 0);

---------------------------------------------------
-- NOTIFICACIÓN PARA CARLOS (reserva confirmada)
---------------------------------------------------
INSERT INTO notifications (
  user_id, title, message,
  notification_type, related_trip_id, is_read
) VALUES
  (2,
   'Reserva confirmada',
   'Tu reserva para el viaje Universidad → Real Plaza ha sido confirmada.',
   'BOOKING', 1, 0);
