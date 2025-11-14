PRAGMA foreign_keys = ON;

---------------------------------------------------
-- 1) MÉTODOS DE PAGO (CATÁLOGO) - 10 filas
---------------------------------------------------
INSERT INTO payment_methods (id, code, name) VALUES
  (1, 'CASH',    'Efectivo'),
  (2, 'CARD',    'Tarjeta de crédito'),
  (3, 'DEBIT',   'Tarjeta de débito'),
  (4, 'YAPE',    'Yape'),
  (5, 'PLIN',    'Plin'),
  (6, 'BANK',    'Transferencia bancaria'),
  (7, 'PAYPAL',  'PayPal'),
  (8, 'APPLE',   'Apple Pay'),
  (9, 'GOOGLE',  'Google Pay'),
  (10,'OTHER',   'Otro método');

---------------------------------------------------
-- 2) USUARIOS - 27 filas (7 conductores + 20 pasajeros)
---------------------------------------------------
INSERT INTO users (id, first_name, last_name, email, password_hash,
                   phone_number, profile_picture, date_of_birth, sex,
                   rating, total_ratings, is_verified, is_active, is_driver)
VALUES
  -- Conductores (1-7)
  (1, 'Ana',     'Gómez',     'ana.gomez@uni.edu',     'hash_ana_123',     '+51 999111001', NULL, '1999-03-15', 'F', 4.8, 25, 1, 1, 1),
  (2, 'Luis',    'Torres',    'luis.torres@uni.edu',   'hash_luis_123',    '+51 999111002', NULL, '1998-07-22', 'M', 4.6, 18, 1, 1, 1),
  (3, 'María',   'Ruiz',      'maria.ruiz@uni.edu',    'hash_maria_123',   '+51 999111003', NULL, '2000-01-09', 'F', 4.9, 32, 1, 1, 1),
  (4, 'Diego',   'Fernández', 'diego.fernandez@uni.edu','hash_diego_123',  '+51 999111004', NULL, '1999-11-30','M', 4.5, 15, 1, 1, 1),
  (5, 'Sofía',   'Rojas',     'sofia.rojas@uni.edu',   'hash_sofia_123',   '+51 999111005', NULL, '2001-05-12','F', 4.7, 20, 1, 1, 1),
  (6, 'Javier',  'Castro',    'javier.castro@uni.edu', 'hash_javier_123',  '+51 999111006', NULL, '1998-09-05','M', 4.4, 10, 1, 1, 1),
  (7, 'Valeria', 'Flores',    'valeria.flores@uni.edu','hash_valeria_123', '+51 999111007', NULL, '2000-02-18','F', 4.9, 40, 1, 1, 1),

  -- Pasajeros (8-27)
  (8,  'Carlos',   'Pérez',    'carlos.perez@uni.edu',   'hash_carlos_123',  '+51 999222008', NULL, '2002-04-10','M', 4.2,  5, 1, 1, 0),
  (9,  'Elena',    'Morales',  'elena.morales@uni.edu',  'hash_elena_123',   '+51 999222009', NULL, '2001-08-03','F', 4.6,  8, 1, 1, 0),
  (10, 'José',     'Ramírez',  'jose.ramirez@uni.edu',   'hash_jose_123',    '+51 999222010', NULL, '2000-12-25','M', 4.1,  3, 1, 1, 0),
  (11, 'Daniela',  'López',    'daniela.lopez@uni.edu',  'hash_daniela_123', '+51 999222011', NULL, '2002-06-19','F', 4.7,  7, 1, 1, 0),
  (12, 'Martín',   'Vega',     'martin.vega@uni.edu',    'hash_martin_123',  '+51 999222012', NULL, '2001-03-29','M', 4.3,  4, 1, 1, 0),
  (13, 'Laura',    'Sánchez',  'laura.sanchez@uni.edu',  'hash_laura_123',   '+51 999222013', NULL, '1999-10-02','F', 4.8,  9, 1, 1, 0),
  (14, 'Pedro',    'Castillo', 'pedro.castillo@uni.edu', 'hash_pedro_123',   '+51 999222014', NULL, '2000-01-30','M', 4.0,  2, 1, 1, 0),
  (15, 'Andrea',   'Navarro',  'andrea.navarro@uni.edu', 'hash_andrea_123',  '+51 999222015', NULL, '2002-02-11','F', 4.5,  6, 1, 1, 0),
  (16, 'Ricardo',  'Gutiérrez','ricardo.gutierrez@uni.edu','hash_ric_123',   '+51 999222016', NULL, '2001-09-15','M', 4.2,  4, 1, 1, 0),
  (17, 'Paula',    'Herrera',  'paula.herrera@uni.edu',  'hash_paula_123',   '+51 999222017', NULL, '2000-05-05','F', 4.6,  5, 1, 1, 0),
  (18, 'Sergio',   'Díaz',     'sergio.diaz@uni.edu',    'hash_sergio_123',  '+51 999222018', NULL, '1999-07-27','M', 4.1,  3, 1, 1, 0),
  (19, 'Mónica',   'Chávez',   'monica.chavez@uni.edu',  'hash_monica_123',  '+51 999222019', NULL, '2001-11-09','F', 4.9, 11, 1, 1, 0),
  (20, 'Gustavo',  'León',     'gustavo.leon@uni.edu',   'hash_gus_123',     '+51 999222020', NULL, '2002-01-20','M', 4.3,  4, 1, 1, 0),
  (21, 'Natalia',  'Campos',   'natalia.campos@uni.edu', 'hash_nat_123',     '+51 999222021', NULL, '2000-08-16','F', 4.4,  5, 1, 1, 0),
  (22, 'Óscar',    'Aguilar',  'oscar.aguilar@uni.edu',  'hash_oscar_123',   '+51 999222022', NULL, '1999-09-01','M', 4.0,  2, 1, 1, 0),
  (23, 'Fernanda', 'Ortiz',    'fernanda.ortiz@uni.edu', 'hash_fer_123',     '+51 999222023', NULL, '2001-02-24','F', 4.7,  6, 1, 1, 0),
  (24, 'Bruno',    'Salinas',  'bruno.salinas@uni.edu',  'hash_bruno_123',   '+51 999222024', NULL, '2002-10-14','M', 4.1,  3, 1, 1, 0),
  (25, 'Camila',   'Paredes',  'camila.paredes@uni.edu', 'hash_camila_123',  '+51 999222025', NULL, '2000-04-08','F', 4.5,  4, 1, 1, 0),
  (26, 'Hernán',   'Rivas',    'hernan.rivas@uni.edu',   'hash_hernan_123',  '+51 999222026', NULL, '1998-12-12','M', 4.2,  3, 1, 1, 0),
  (27, 'Lucero',   'Medina',   'lucero.medina@uni.edu',  'hash_lucero_123',  '+51 999222027', NULL, '2001-06-01','F', 4.6,  5, 1, 1, 0);

---------------------------------------------------
-- 3) CONFIGURACIÓN DE USUARIO (user_settings) - 27 filas
---------------------------------------------------
INSERT INTO user_settings (id, user_id, notifications_enabled, dark_mode_enabled) VALUES
  (1, 1, 1, 0),
  (2, 2, 1, 0),
  (3, 3, 1, 1),
  (4, 4, 1, 0),
  (5, 5, 1, 1),
  (6, 6, 1, 0),
  (7, 7, 1, 1),
  (8, 8, 1, 0),
  (9, 9, 1, 1),
  (10,10,1, 0),
  (11,11,1, 0),
  (12,12,1, 1),
  (13,13,1, 0),
  (14,14,1, 0),
  (15,15,1, 1),
  (16,16,1, 0),
  (17,17,1, 1),
  (18,18,1, 0),
  (19,19,1, 1),
  (20,20,1, 0),
  (21,21,1, 0),
  (22,22,1, 0),
  (23,23,1, 1),
  (24,24,1, 0),
  (25,25,1, 1),
  (26,26,1, 0),
  (27,27,1, 1);

---------------------------------------------------
-- 4) VEHÍCULOS - 10 filas (algunos conductores tienen 2)
---------------------------------------------------
INSERT INTO vehicles (id, user_id, make, model, year, color,
                      license_plate, capacity, vehicle_photo,
                      insurance_verified)
VALUES
  (1, 1, 'Toyota',   'Yaris',    2019, 'Rojo',    'ABC-123', 4, NULL, 1),
  (2, 2, 'Kia',      'Rio',      2018, 'Azul',    'BCD-234', 4, NULL, 1),
  (3, 3, 'Hyundai',  'Accent',   2020, 'Blanco',  'CDE-345', 4, NULL, 1),
  (4, 4, 'Chevrolet','Spark',    2017, 'Verde',   'DEF-456', 3, NULL, 0),
  (5, 5, 'Nissan',   'Versa',    2021, 'Negro',   'EFG-567', 4, NULL, 1),
  (6, 6, 'Suzuki',   'Swift',    2019, 'Gris',    'FGH-678', 4, NULL, 1),
  (7, 7, 'Volkswagen','Gol',     2018, 'Plateado','GHI-789', 4, NULL, 1),
  -- Vehículos adicionales para algunos conductores
  (8, 1, 'Toyota',   'Corolla',  2020, 'Gris',    'HIJ-890', 4, NULL, 1),
  (9, 3, 'Honda',    'Fit',      2016, 'Azul',    'IJK-901', 4, NULL, 0),
  (10,5, 'Kia',      'Picanto',  2017, 'Amarillo','JKL-012', 3, NULL, 1);

---------------------------------------------------
-- 5) VIAJES - 14 filas (2 por cada conductor 1-7)
---------------------------------------------------
INSERT INTO trips (id, driver_id, vehicle_id,
                   origin_address, origin_latitude, origin_longitude,
                   destination_address, destination_latitude, destination_longitude,
                   departure_datetime, estimated_arrival_datetime,
                   available_seats, price_per_seat,
                   trip_status, meeting_point, notes)
VALUES
  -- Ana (1) con veh 1 y 8
  (1, 1, 1, 'Campus Universitario',   -12.0600, -77.0800,
      'Real Plaza Centro',           -12.0620, -77.0500,
      '2025-11-20 08:00', '2025-11-20 08:40',
      3, 7.50, 'PENDING', 'Puerta principal del campus', 'Viaje de prueba mañanero'),
  (2, 1, 8, 'Campus Universitario',   -12.0600, -77.0800,
      'Terminal Terrestre',          -12.0700, -77.0300,
      '2025-11-20 18:00', '2025-11-20 18:45',
      3, 8.00, 'PENDING', 'Frente a biblioteca', 'Regreso al final del día'),

  -- Luis (2) veh 2
  (3, 2, 2, 'Residencial Universitaria', -12.0580, -77.0900,
      'Campus Universitario',           -12.0600, -77.0800,
      '2025-11-21 07:20', '2025-11-21 07:40',
      3, 5.50, 'PENDING', 'Entrada principal', 'Ruta corta hacia el campus'),
  (4, 2, 2, 'Campus Universitario',     -12.0600, -77.0800,
      'Mall Aventura',                  -12.0750, -77.0400,
      '2025-11-21 17:10', '2025-11-21 17:50',
      2, 6.50, 'PENDING', 'Paradero frente a cafetería', 'Salida después de clases'),

  -- María (3) veh 3 y 9
  (5, 3, 3, 'Campus Universitario',     -12.0600, -77.0800,
      'Plaza San Martín',               -12.0460, -77.0300,
      '2025-11-22 09:00', '2025-11-22 09:40',
      3, 7.00, 'PENDING', 'Estacionamiento norte', 'Ruta directa por vía expresa'),
  (6, 3, 9, 'Plaza San Martín',         -12.0460, -77.0300,
      'Campus Universitario',           -12.0600, -77.0800,
      '2025-11-22 18:30', '2025-11-22 19:10',
      3, 7.00, 'PENDING', 'Costado de la pileta', 'Regreso al campus'),

  -- Diego (4) veh 4
  (7, 4, 4, 'Campus Universitario',     -12.0600, -77.0800,
      'Estación Metropolitano',         -12.0500, -77.0600,
      '2025-11-23 08:15', '2025-11-23 08:35',
      2, 4.50, 'PENDING', 'Puerta lateral', 'Ideal para conexiones al Metropolitano'),
  (8, 4, 4, 'Estación Metropolitano',   -12.0500, -77.0600,
      'Campus Universitario',           -12.0600, -77.0800,
      '2025-11-23 17:05', '2025-11-23 17:25',
      2, 4.50, 'PENDING', 'Entrada principal estación', 'Regreso al campus por la tarde'),

  -- Sofía (5) veh 5 y 10
  (9,  5, 5,  'Distrito Cercano A',     -12.0700, -77.0900,
      'Campus Universitario',           -12.0600, -77.0800,
      '2025-11-24 07:30', '2025-11-24 07:55',
      3, 6.00, 'PENDING', 'Parque central de A', 'Compartir gasto de gasolina'),
  (10, 5, 10, 'Campus Universitario',   -12.0600, -77.0800,
      'Distrito Cercano A',             -12.0700, -77.0900,
      '2025-11-24 18:10', '2025-11-24 18:35',
      3, 6.00, 'PENDING', 'Puerta principal', 'Regreso a Distrito A'),

  -- Javier (6) veh 6
  (11, 6, 6, 'Campus Universitario',    -12.0600, -77.0800,
      'Parque Industrial',              -12.0800, -77.0200,
      '2025-11-25 08:10', '2025-11-25 08:50',
      3, 8.50, 'PENDING', 'Paradero frente a estadio', 'Ruta algo más larga'),
  (12, 6, 6, 'Parque Industrial',       -12.0800, -77.0200,
      'Campus Universitario',           -12.0600, -77.0800,
      '2025-11-25 17:20', '2025-11-25 18:00',
      3, 8.50, 'PENDING', 'Entrada principal del parque', 'Regreso al campus'),

  -- Valeria (7) veh 7
  (13, 7, 7, 'Residencial B',           -12.0650, -77.0950,
      'Campus Universitario',           -12.0600, -77.0800,
      '2025-11-26 07:40', '2025-11-26 08:05',
      3, 5.00, 'PENDING', 'Parque de la residencial', 'Ruta rápida sin peajes'),
  (14, 7, 7, 'Campus Universitario',    -12.0600, -77.0800,
      'Residencial B',                  -12.0650, -77.0950,
      '2025-11-26 18:00', '2025-11-26 18:25',
      3, 5.00, 'PENDING', 'Puerta principal', 'Regreso a la residencial');

---------------------------------------------------
-- 6) STOPS - 10 filas (2 por los 5 primeros viajes)
---------------------------------------------------
INSERT INTO stops (id, trip_id, stop_address, stop_latitude, stop_longitude, stop_order, estimated_arrival_time) VALUES
  (1, 1, 'Paradero Facultad de Ingeniería', -12.0590, -77.0780, 1, '2025-11-20 08:10'),
  (2, 1, 'Paradero Clínica Universitaria',  -12.0610, -77.0700, 2, '2025-11-20 08:25'),

  (3, 2, 'Paradero Biblioteca Central',     -12.0595, -77.0790, 1, '2025-11-20 18:10'),
  (4, 2, 'Paradero Óvalo Universitario',    -12.0625, -77.0720, 2, '2025-11-20 18:25'),

  (5, 3, 'Paradero Cafetería Norte',        -12.0585, -77.0880, 1, '2025-11-21 07:25'),
  (6, 3, 'Puerta principal campus',         -12.0600, -77.0800, 2, '2025-11-21 07:35'),

  (7, 4, 'Paradero gimnasio',               -12.0590, -77.0795, 1, '2025-11-21 17:20'),
  (8, 4, 'Puerta salida hacia Mall',        -12.0630, -77.0730, 2, '2025-11-21 17:35'),

  (9, 5, 'Paradero Escuela de Postgrado',   -12.0588, -77.0792, 1, '2025-11-22 09:10'),
  (10,5, 'Paradero Av. Principal',          -12.0520, -77.0600, 2, '2025-11-22 09:25');

---------------------------------------------------
-- 7) BOOKINGS - 28 filas (1-3 reservas por viaje)
-- Usamos pasajeros 8-27
---------------------------------------------------
INSERT INTO bookings (id, trip_id, passenger_id, seats_reserved,
                      total_price, booking_status, pickup_location)
VALUES
  -- Trip 1 (Ana mañana)
  (1, 1,  8, 1, 7.50, 'CONFIRMED', 'Paradero Facultad de Ingeniería'),
  (2, 1,  9, 1, 7.50, 'CONFIRMED', 'Paradero Clínica Universitaria'),
  (3, 1, 10, 1, 7.50, 'PENDING',   'Puerta principal'),

  -- Trip 2 (Ana tarde)
  (4, 2, 11, 1, 8.00, 'CONFIRMED', 'Biblioteca Central'),
  (5, 2, 12, 1, 8.00, 'CONFIRMED', 'Óvalo Universitario'),

  -- Trip 3 (Luis entrada)
  (6, 3, 13, 1, 5.50, 'CONFIRMED', 'Residencial Universitaria'),
  (7, 3, 14, 1, 5.50, 'PENDING',   'Paradero Cafetería Norte'),

  -- Trip 4 (Luis salida)
  (8, 4, 15, 1, 6.50, 'CONFIRMED', 'Puerta cafetería'),
  (9, 4, 16, 1, 6.50, 'PENDING',   'Paradero gimnasio'),

  -- Trip 5 (María ida)
  (10,5, 17, 1, 7.00, 'CONFIRMED', 'Paradero Escuela de Postgrado'),
  (11,5, 18, 1, 7.00, 'CONFIRMED', 'Paradero Av. Principal'),

  -- Trip 6 (María retorno)
  (12,6, 19, 1, 7.00, 'CONFIRMED', 'Costado de la pileta'),
  (13,6, 20, 1, 7.00, 'PENDING',   'Paradero Plaza San Martín'),

  -- Trip 7 (Diego ida)
  (14,7, 21, 1, 4.50, 'CONFIRMED', 'Puerta lateral'),
  (15,7, 22, 1, 4.50, 'PENDING',   'Paradero intermedio'),

  -- Trip 8 (Diego retorno)
  (16,8, 23, 1, 4.50, 'CONFIRMED', 'Entrada principal estación'),
  (17,8, 24, 1, 4.50, 'CONFIRMED', 'Paradero frente a estación'),

  -- Trip 9 (Sofía ida)
  (18,9, 25, 1, 6.00, 'CONFIRMED', 'Parque central de A'),
  (19,9, 26, 1, 6.00, 'PENDING',   'Paradero secundario A'),

  -- Trip 10 (Sofía retorno)
  (20,10,27, 1, 6.00, 'CONFIRMED', 'Puerta principal campus'),

  -- Trip 11 (Javier ida)
  (21,11, 8, 1, 8.50, 'CONFIRMED', 'Paradero estadio'),
  (22,11, 9,  1, 8.50, 'PENDING',  'Paradero intermedio'),

  -- Trip 12 (Javier retorno)
  (23,12,10, 1, 8.50, 'CONFIRMED', 'Entrada parque industrial'),
  (24,12,11, 1, 8.50, 'CONFIRMED', 'Paradero Av. Principal'),

  -- Trip 13 (Valeria ida)
  (25,13,12, 1, 5.00, 'CONFIRMED', 'Parque residencial B'),
  (26,13,13, 1, 5.00, 'PENDING',   'Paradero frente a farmacia'),

  -- Trip 14 (Valeria retorno)
  (27,14,14, 1, 5.00, 'CONFIRMED', 'Puerta principal campus'),
  (28,14,15, 1, 5.00, 'CONFIRMED', 'Paradero interno campus');

---------------------------------------------------
-- 8) MÉTODOS DE PAGO DEL USUARIO (user_payment_methods) - 15 filas
-- Algunos pasajeros usan tarjeta/Yape/Plin, otros solo efectivo
---------------------------------------------------
INSERT INTO user_payment_methods (id, user_id, payment_method_id,
                                  card_brand, card_last4, card_holder_name,
                                  expiry_month, expiry_year, is_default)
VALUES
  (1,  8, 2, 'Visa',      '1111', 'Carlos Pérez',       12, 2027, 1),
  (2,  9, 2, 'Mastercard','2222', 'Elena Morales',      11, 2026, 1),
  (3, 10, 3, 'Visa Débito','3333','José Ramírez',       10, 2025, 1),
  (4, 11, 2, 'Visa',      '4444', 'Daniela López',       9, 2027, 1),
  (5, 12, 4, NULL,        NULL,   'Martín Vega Yape',   NULL, NULL,1),
  (6, 13, 5, NULL,        NULL,   'Laura Sánchez Plin', NULL, NULL,1),
  (7, 17, 2, 'Visa',      '5555', 'Paula Herrera',       8, 2026, 1),
  (8, 18, 2, 'Visa',      '6666', 'Sergio Díaz',         7, 2025, 1),
  (9, 19, 2, 'Visa',      '7777', 'Mónica Chávez',       6, 2027, 1),
  (10,20, 3, 'Débito',    '8888', 'Gustavo León',        5, 2026, 1),
  (11,21, 2, 'Visa',      '9999', 'Natalia Campos',      4, 2027, 1),
  (12,22, 2, 'Visa',      '1234', 'Óscar Aguilar',       3, 2025, 1),
  (13,23, 2, 'Visa',      '2345', 'Fernanda Ortiz',      2, 2026, 1),
  (14,24, 3, 'Débito',    '3456', 'Bruno Salinas',       1, 2026, 1),
  (15,25, 2, 'Visa',      '4567', 'Camila Paredes',     12, 2028, 1);

---------------------------------------------------
-- 9) PAGOS (payments) - 24 filas (solo para reservas CONFIRMED)
-- booking_id que tengan booking_status = 'CONFIRMED'
---------------------------------------------------
INSERT INTO payments (id, booking_id, user_payment_method_id,
                      amount, payment_status, transaction_id, payment_date)
VALUES
  (1,  1,  1,  7.50, 'PAID', 'TXN-0001', '2025-11-19 20:10'),
  (2,  2,  2,  7.50, 'PAID', 'TXN-0002', '2025-11-19 20:12'),
  (3,  4,  4,  8.00, 'PAID', 'TXN-0003', '2025-11-20 10:00'),
  (4,  5,  5,  8.00, 'PAID', 'TXN-0004', '2025-11-20 10:05'),
  (5,  6,  6,  5.50, 'PAID', 'TXN-0005', '2025-11-20 21:00'),
  (6,  8,  7,  6.50, 'PAID', 'TXN-0006', '2025-11-21 12:00'),
  (7, 10,  8,  7.00, 'PAID', 'TXN-0007', '2025-11-21 16:00'),
  (8, 11,  9,  7.00, 'PAID', 'TXN-0008', '2025-11-21 16:05'),
  (9, 12, 10,  7.00, 'PAID', 'TXN-0009', '2025-11-21 16:10'),
  (10,14, 11,  4.50, 'PAID', 'TXN-0010', '2025-11-22 07:50'),
  (11,16, 12,  4.50, 'PAID', 'TXN-0011', '2025-11-22 16:30'),
  (12,17, 13,  4.50, 'PAID', 'TXN-0012', '2025-11-22 16:32'),
  (13,18, 14,  6.00, 'PAID', 'TXN-0013', '2025-11-23 07:40'),
  (14,20,  1,  6.00, 'PAID', 'TXN-0014', '2025-11-23 17:20'),
  (15,21,  2,  8.50, 'PAID', 'TXN-0015', '2025-11-24 07:50'),
  (16,23,  3,  8.50, 'PAID', 'TXN-0016', '2025-11-24 17:30'),
  (17,24,  4,  8.50, 'PAID', 'TXN-0017', '2025-11-24 17:32'),
  (18,25,  5,  5.00, 'PAID', 'TXN-0018', '2025-11-25 07:55'),
  (19,27,  6,  5.00, 'PAID', 'TXN-0019', '2025-11-25 18:10'),
  (20,28,  7,  5.00, 'PAID', 'TXN-0020', '2025-11-25 18:12'),
  -- algunos pagos en efectivo (sin user_payment_method_id)
  (21, 3, NULL, 7.50, 'PAID', 'CASH-0001', '2025-11-19 20:15'),
  (22, 7, NULL, 5.50, 'PAID', 'CASH-0002', '2025-11-20 21:05'),
  (23, 9, NULL, 6.50, 'PAID', 'CASH-0003', '2025-11-21 12:10'),
  (24,13, NULL, 7.00, 'PAID', 'CASH-0004', '2025-11-21 16:15');

---------------------------------------------------
-- 10) RESEÑAS (reviews) - 18 filas
-- Pasajeros califican a conductores después de viajes
---------------------------------------------------
INSERT INTO reviews (id, reviewer_id, reviewed_user_id,
                     trip_id, rating, comment, is_anonymous)
VALUES
  (1,  8,  1, 1, 5, 'Ana fue muy puntual y amable.', 0),
  (2,  9,  1, 1, 4, 'Buen viaje, auto limpio.', 0),
  (3, 11,  1, 2, 5, 'Me avisó por chat antes de llegar.', 0),
  (4, 13,  2, 3, 4, 'Luis maneja tranquilo.', 0),
  (5, 15,  2, 4, 5, 'Buena música y conversamos agradable.', 0),
  (6, 17,  3, 5, 5, 'María fue súper amable.', 0),
  (7, 18,  3, 5, 4, 'Llegamos a tiempo, un poco de tráfico.', 1),
  (8, 19,  3, 6, 5, 'Me esperó aunque llegué algo tarde.', 0),
  (9, 21,  4, 7, 4, 'Diego conoce rutas alternas.', 0),
  (10,23,  4, 8, 5, 'Muy buen conductor.', 0),
  (11,25,  5, 9, 5, 'Sofía explicó bien el punto de encuentro.', 0),
  (12,27,  5,10, 4, 'Auto cómodo, regresamos rápido.', 0),
  (13, 8,  6,11, 4, 'Javier maneja un poco rápido, pero bien.', 1),
  (14,10,  6,12, 5, 'Muy atento con todos.', 0),
  (15,12,  7,13, 5, 'Valeria fue muy puntual.', 0),
  (16,14,  7,14, 4, 'Buen viaje en general.', 0),
  -- una reseña pasajero -> pasajero (p.e. comportamiento dentro del auto)
  (17,13,  8, 1, 5, 'Carlos fue respetuoso y puntual.', 1),
  (18,15,  9, 4, 4, 'Elena fue agradable durante el viaje.', 1);

---------------------------------------------------
-- 11) REPORTES (reports) - 10 filas
---------------------------------------------------
INSERT INTO reports (id, reporter_id, reported_user_id, trip_id,
                     problem_type, description, status)
VALUES
  (1,  9,  1, 1,  'CONDUCTOR', 'El auto llegó 10 minutos tarde.', 'IN_REVIEW'),
  (2, 10,  2, 3,  'CONDUCTOR', 'Conducción un poco brusca.',      'PENDING'),
  (3, 18,  3, 6,  'CONDUCTOR', 'Música muy alta, pero se corrigió.', 'RESOLVED'),
  (4, 22,  4, 7,  'CONDUCTOR', 'No respetó una luz ámbar.',       'PENDING'),
  (5, 11,  8, 2,  'PASAJERO',  'El pasajero casi no usaba cinturón.', 'PENDING'),
  (6, 13, 14, 4,  'PASAJERO',  'Llegó muy tarde al punto de encuentro.', 'IN_REVIEW'),
  (7, 17, NULL,  5,  'OTRO',  'Tráfico fuerte, el viaje demoró más de lo esperado.', 'RESOLVED'),
  (8, 19, NULL,  9,  'OTRO',  'Ruta distinta a la planificada, pero segura.', 'RESOLVED'),
  (9, 21,  6, 11, 'CONDUCTOR','Conductor revisaba el celular en el semáforo.', 'IN_REVIEW'),
  (10,25,  7, 13, 'CONDUCTOR','Falta de aire acondicionado, hizo mucho calor.', 'PENDING');

---------------------------------------------------
-- 12) MENSAJES (messages) - 25 filas
-- Chat entre pasajeros y conductores
---------------------------------------------------
INSERT INTO messages (id, trip_id, sender_id, receiver_id, message_text, is_read)
VALUES
  -- Trip 1 (Ana con varios pasajeros)
  (1,  1,  8,  1, 'Hola Ana, estaré en el paradero de Ingeniería.', 0),
  (2,  1,  1,  8, 'Perfecto, te recojo a las 8:10 😊', 1),
  (3,  1,  9,  1, '¿Puedes avisar cuando estés cerca de la clínica?', 0),
  (4,  1,  1,  9, 'Claro, te escribo 5 min antes.', 1),

  -- Trip 2
  (5,  2, 11,  1, 'Estoy en la biblioteca, ¿dónde te encuentro?', 1),
  (6,  2,  1, 11, 'Frente a la puerta principal de la biblio.', 1),

  -- Trip 3
  (7,  3, 13,  2, 'Voy con mochila grande, ¿hay espacio?', 1),
  (8,  3,  2, 13, 'Sí, sin problema 👍', 1),

  -- Trip 4
  (9,  4, 15,  2, 'Llegaré justo a la hora, ¿me esperas?', 0),
  (10, 4,  2, 15, 'Te espero 5 minutos máximo, porfa.', 0),

  -- Trip 5
  (11, 5, 17,  3, '¿Puedes dejarme antes de la plaza principal?', 1),
  (12, 5,  3, 17, 'Sí, te dejo en el primer paradero.', 1),

  -- Trip 7
  (13, 7, 21,  4, 'Estoy en la puerta lateral, con casaca azul.', 1),
  (14, 7,  4, 21, 'Te veo, ya voy llegando.', 1),

  -- Trip 9
  (15, 9, 25,  5, 'Hola Sofía, ¿hay tráfico por tu ruta?', 0),
  (16, 9,  5, 25, 'Un poco, pero llegamos a tiempo.', 0),

  -- Trip 11
  (17,11, 8,   6, 'Javier, estoy cerca del estadio.', 1),
  (18,11,  6,  8, 'Perfecto, nos vemos en 5 minutos.', 1),

  -- Trip 12
  (19,12,10,   6, '¿Puedes dejarme en el paradero de Av. Principal?', 1),
  (20,12,  6, 10, 'Sí, ahí te dejo.', 1),

  -- Trip 13
  (21,13,12,   7, 'Estoy en el parque residencial.', 1),
  (22,13,  7, 12, 'Perfecto, ya salgo.', 1),

  -- Trip 14
  (23,14,14,   7, 'Gracias por el viaje de regreso 🙌', 1),
  (24,14,  7, 14, 'De nada, nos vemos mañana.', 1),
  (25,14,15,   7, 'Valeria, gracias por esperarme.', 0);

---------------------------------------------------
-- 13) NOTIFICACIONES (notifications) - 30 filas
---------------------------------------------------
INSERT INTO notifications (id, user_id, title, message,
                           notification_type, related_trip_id, is_read)
VALUES
  -- Reservas confirmadas
  (1,  8, 'Reserva confirmada', 'Tu reserva en el viaje de Ana (Campus → Real Plaza) ha sido confirmada.', 'BOOKING', 1, 0),
  (2,  9, 'Reserva confirmada', 'Tu reserva en el viaje de Ana (Campus → Real Plaza) ha sido confirmada.', 'BOOKING', 1, 0),
  (3, 11, 'Reserva confirmada', 'Tu reserva en el viaje de Ana (Campus → Terminal) ha sido confirmada.', 'BOOKING', 2, 1),
  (4, 13, 'Reserva confirmada', 'Tu reserva en el viaje de Luis (Residencial → Campus) ha sido confirmada.', 'BOOKING', 3, 1),
  (5, 15, 'Reserva confirmada', 'Tu reserva en el viaje de Luis (Campus → Mall) ha sido confirmada.', 'BOOKING', 4, 0),
  (6, 17, 'Reserva confirmada', 'Tu reserva en el viaje de María (Campus → Plaza San Martín) ha sido confirmada.', 'BOOKING', 5, 1),
  (7, 19, 'Reserva confirmada', 'Tu reserva en el viaje de María (Plaza San Martín → Campus) ha sido confirmada.', 'BOOKING', 6, 1),
  (8, 21, 'Reserva confirmada', 'Tu reserva en el viaje de Diego (Campus → Estación Metropolitano) ha sido confirmada.', 'BOOKING', 7, 0),
  (9, 23, 'Reserva confirmada', 'Tu reserva en el viaje de Diego (Estación → Campus) ha sido confirmada.', 'BOOKING', 8, 1),
  (10,25,'Reserva confirmada', 'Tu reserva en el viaje de Sofía (Distrito A → Campus) ha sido confirmada.', 'BOOKING', 9, 1),
  (11,27,'Reserva confirmada', 'Tu reserva en el viaje de Sofía (Campus → Distrito A) ha sido confirmada.', 'BOOKING', 10,1),
  (12, 8, 'Reserva confirmada', 'Tu reserva en el viaje de Javier (Campus → Parque Industrial) ha sido confirmada.', 'BOOKING', 11,1),
  (13,10, 'Reserva confirmada', 'Tu reserva en el viaje de Javier (Parque Industrial → Campus) ha sido confirmada.', 'BOOKING', 12,1),
  (14,12, 'Reserva confirmada', 'Tu reserva en el viaje de Valeria (Residencial B → Campus) ha sido confirmada.', 'BOOKING', 13,1),
  (15,14, 'Reserva confirmada', 'Tu reserva en el viaje de Valeria (Campus → Residencial B) ha sido confirmada.', 'BOOKING', 14,0),

  -- Pagos realizados
  (16, 8, 'Pago exitoso', 'Tu pago de S/ 7.50 por el viaje de Ana fue procesado correctamente.', 'PAYMENT', 1, 1),
  (17, 9, 'Pago exitoso', 'Tu pago de S/ 7.50 por el viaje de Ana fue procesado correctamente.', 'PAYMENT', 1, 1),
  (18,11, 'Pago exitoso', 'Tu pago de S/ 8.00 por el viaje de Ana (tarde) fue procesado correctamente.', 'PAYMENT', 2, 1),
  (19,13, 'Pago exitoso', 'Tu pago de S/ 5.50 por el viaje de Luis fue procesado correctamente.', 'PAYMENT', 3, 1),
  (20,17, 'Pago exitoso', 'Tu pago de S/ 7.00 por el viaje de María fue procesado correctamente.', 'PAYMENT', 5, 1),

  -- Mensajes nuevos
  (21, 1, 'Nuevo mensaje', 'Has recibido un mensaje de Carlos para el viaje 1.', 'MESSAGE', 1, 0),
  (22, 1, 'Nuevo mensaje', 'Has recibido un mensaje de Elena para el viaje 1.', 'MESSAGE', 1, 1),
  (23, 2, 'Nuevo mensaje', 'Has recibido un mensaje de Andrea para el viaje 4.', 'MESSAGE', 4, 0),
  (24, 3, 'Nuevo mensaje', 'Has recibido un mensaje de Paula para el viaje 5.', 'MESSAGE', 5, 1),
  (25, 5, 'Nuevo mensaje', 'Has recibido un mensaje de Camila para el viaje 9.', 'MESSAGE', 9, 0),

  -- Reseñas recibidas
  (26, 1, 'Nueva reseña recibida', 'Has recibido una nueva reseña de 5 estrellas.', 'REVIEW', 1, 0),
  (27, 2, 'Nueva reseña recibida', 'Has recibido una reseña de 4 estrellas.', 'REVIEW', 3, 0),
  (28, 3, 'Nueva reseña recibida', 'Has recibido una reseña de 5 estrellas.', 'REVIEW', 5, 1),
  (29, 4, 'Nueva reseña recibida', 'Has recibido una reseña de 4 estrellas.', 'REVIEW', 7, 1),
  (30, 5, 'Nueva reseña recibida', 'Has recibido una reseña de 5 estrellas.', 'REVIEW', 9, 1);

---------------------------------------------------
-- 14) HELP ARTICLES (FAQ) - 10 filas
---------------------------------------------------
INSERT INTO help_articles (id, question, answer, category) VALUES
  (1, '¿Cómo reservo un viaje?', 'Selecciona un viaje disponible, revisa los detalles y pulsa en "Reservar".', 'VIAJES'),
  (2, '¿Cómo cancelo una reserva?', 'Desde tu historial de viajes, elige la reserva y pulsa en "Cancelar".', 'VIAJES'),
  (3, '¿Qué métodos de pago puedo usar?', 'Puedes usar efectivo, tarjeta, Yape, Plin y otros métodos configurados.', 'PAGOS'),
  (4, '¿Cómo califico a un conductor?', 'Después de completar un viaje, podrás dejar una reseña en la sección "Historial".', 'RESEÑAS'),
  (5, '¿Cómo reporto un problema?', 'Desde el detalle del viaje, pulsa en "Reportar problema" y completa el formulario.', 'SEGURIDAD'),
  (6, '¿Puedo cambiar mi método de pago?', 'Sí, en la sección "Métodos de pago" puedes agregar, editar o eliminar tarjetas.', 'PAGOS'),
  (7, '¿Cómo activo las notificaciones?', 'En Configuración puedes activar o desactivar las notificaciones de la app.', 'CONFIGURACIÓN'),
  (8, '¿Quién puede ser conductor?', 'Usuarios verificados que registren un vehículo y sean aprobados como conductores.', 'CONDUCTORES'),
  (9, '¿Es seguro usar CarpoolU?', 'Promovemos reseñas, reportes y verificación de usuarios para mayor seguridad.', 'SEGURIDAD'),
  (10,'¿Puedo usar CarpoolU solo como pasajero?', 'Sí, puedes usar la app solo como pasajero si no deseas conducir.', 'VIAJES');
