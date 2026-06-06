-- 1) Vehículos
INSERT INTO vehiculos(matricula, modelo, marca, color) VALUES
('1111AAA','GTI','Nissan','Negro'),
('2222BBB','TDI','Volkswagen','Azul'),
('3333CCC','Fiesta','Ford','Blanco'),
('4444DDD','Getz','Hyundai','Gris'),
('5555EEE','Corolla','Toyota','Rojo'),
('6666FFF','Ibiza','SEAT','Blanco'),
('7777GGG','Clio','Renault','Gris'),
('8888HHH','Corsa','Opel','Azul'),
('9999JJJ','Polo','Volkswagen','Negro'),
('0000KKK','208','Peugeot','Rojo'),
('1212LLL','Focus','Ford','Azul'),
('3434MMM','Astra','Opel','Gris'),
('5656NNN','i20','Hyundai','Blanco'),
('7878PPP','Yaris','Toyota','Negro'),
('9090RRR','Golf','Volkswagen','Gris');

--------------------------------------------------
-- 2) PERSONAS (empleados 1–15)
INSERT INTO personas(nombre, apellido1, apellido2, dni, fecha_nac, direccion, telefono) VALUES
('Anxo','Curras',NULL,'12345678X','2000-11-10','Calle Calvar 99','123 456 789'),
('Angel','Mendez',NULL,'87654321Z','1999-07-11','Calle Pilar 87','222 222 222'),
('Xurxo','Fisterra','Sotelo','24681357R','1998-02-12','Calle Santarosa 14','333 333 333'),
('Jorge','Lago','Cordeiro','78945612T','1996-04-13','Calle Eduardo Chaves 69','444 444 444'),
('Miguel','Chaves','Gonzales','32165498Y','1997-09-14','Calle Piñeiro 3','555 555 555'),
('Pepe','Del Rio',NULL,'15975346H','1988-01-15','Calle Calvar 1','666 666 666'),
('Manuel','Magallanes',NULL,'46829715L','1985-03-16','Calle Piñeiro 33','777 777 777'),
('Xian','Pazo','Quente','90753124M','1990-05-17','Calle Santarosa 66','888 888 888'),
('Juan','Soto','Silva','58241976K','1989-06-18','Calle Eduardo Chaves 9','999 999 999'),
('Marta','Reina',NULL,'73486219P','1991-08-19','Calle Pilar 87','111 111 111'),
('Noa','Varela',NULL,'11223344A','1993-10-20','Rua do Sol 7','111 222 333'),
('Iria','Dominguez','Lopez','22334455B','1992-12-21','Avd Galicia 12','222 333 444'),
('Hugo','Pereira',NULL,'33445566C','1987-11-22','Rua Nova 5','333 444 555'),
('Lara','Suarez','Mato','44556677D','1994-02-23','Calle Palmas 3','444 555 666'),
('Brais','Molina',NULL,'55667788E','1986-07-24','Rua San Xoan 10','555 666 777');


INSERT INTO empleados(idpersona,nombre, apellido1, apellido2, dni, fecha_nac, direccion, telefono,idjefe, telefonos_empresa) VALUES
  (1,'Anxo','Curras',NULL,'12345678X','2000-11-10','Calle Calvar 99','123 456 789', NULL, ARRAY['981 111 111']),
  (2,'Angel','Mendez',NULL,'87654321Z','1999-07-11','Calle Pilar 87','222 222 222', NULL,    ARRAY['981 111 112','981 111 212']),
  (3, 'Xurxo','Fisterra','Sotelo','24681357R','1998-02-12','Calle Santarosa 14','333 333 333',NULL,    ARRAY['981 111 113']),
  (4,'Jorge','Lago','Cordeiro','78945612T','1996-04-13','Calle Eduardo Chaves 69','444 444 444', NULL,    ARRAY['981 111 114']),
  (5,'Miguel','Chaves','Gonzales','32165498Y','1997-09-14','Calle Piñeiro 3','555 555 555', NULL,    ARRAY['981 111 115']),
  (6, 'Pepe','Del Rio',NULL,'15975346H','1988-01-15','Calle Calvar 1','666 666 666',NULL,    ARRAY['981 111 116']),
  (7,'Manuel','Magallanes',NULL,'46829715L','1985-03-16','Calle Piñeiro 33','777 777 777',NULL,    ARRAY['981 111 117']),
  (8, 'Xian','Pazo','Quente','90753124M','1990-05-17','Calle Santarosa 66','888 888 888',NULL,    ARRAY['981 111 118']),
  (9, 'Juan','Soto','Silva','58241976K','1989-06-18','Calle Eduardo Chaves 9','999 999 999',NULL,    ARRAY['981 111 119']),
  (10,'Marta','Reina',NULL,'73486219P','1991-08-19','Calle Pilar 87','111 111 111',NULL,    ARRAY['981 111 120']),
  (11,'Noa','Varela',NULL,'11223344A','1993-10-20','Rua do Sol 7','111 222 333',NULL,    ARRAY['981 111 121']),
  (12,'Iria','Dominguez','Lopez','22334455B','1992-12-21','Avd Galicia 12','222 333 444',NULL,    ARRAY['981 111 122']),
  (13,'Hugo','Pereira',NULL,'33445566C','1987-11-22','Rua Nova 5','333 444 555',NULL,    ARRAY['981 111 123']),
  (14,'Lara','Suarez','Mato','44556677D','1994-02-23','Calle Palmas 3','444 555 666',NULL,    ARRAY['981 111 124']),
  (15,'Brais','Molina',NULL,'55667788E','1986-07-24','Rua San Xoan 10','555 666 777',NULL,    ARRAY['981 111 125']);


--------------------------------------------------
-- 4) PERSONAS (estudiantes 16–30)
INSERT INTO personas(nombre, apellido1, apellido2, dni, fecha_nac, direccion, telefono) VALUES
('Sebas','Vazques','Rios','11112222T','2008-11-15','Calle Calvar 1','666 666 666'),
('Aron','Martinez',NULL,'33334444R','2008-11-16','Calle Pilar 8771','777 777 777'),
('Marcos','Antepazo','Ferradas','55556666Y','2008-11-17','Calle Santarosa 87','888 888 888'),
('Alejandro','Perez',NULL,'77778888Q','2008-11-18','Calle Eduardo Chaves 13','999 999 999'),
('Javi','Pucelas','Pereira','99998765S','2008-11-19','Calle Piñeiro 45','111 999 555'),
('Nerea','Santos',NULL,'66778899F','2007-01-05','Rua do Regueiro 15','600 000 001'),
('Adrian','Gomez','Paz','77889900G','2007-02-06','Rua do Regueiro 15','600 000 002'),
('Lucia','Rodriguez',NULL,'88990011I','2007-03-07','Rua do Regueiro 15','600 000 003'),
('Pablo','Alvarez','Seoane','99001122J','2007-04-08','Rua do Regueiro 15','600 000 004'),
('Sara','Prieto',NULL,'10101010K','2007-05-09','Rua do Regueiro 15','600 000 005'),
('Diego','Vazquez',NULL,'20202020L','2007-06-10','Calle Calvar 22','600 000 006'),
('Ainhoa','Crespo','Lage','30303030M','2007-07-11','Calle Calvar 23','600 000 007'),
('Izan','Nogueira',NULL,'40404040N','2007-08-12','Calle Calvar 24','600 000 008'),
('Carla','Souto','Pita','50505050O','2007-09-13','Calle Calvar 25','600 000 009'),
('Eric','Vidal',NULL,'60606060R','2007-10-14','Calle Calvar 26','600 000 010');



INSERT INTO estudiantes(idpersona,nombre, apellido1, apellido2, dni, fecha_nac, direccion, telefono, idvehiculo) VALUES
  (16,'Sebas','Vazques','Rios','11112222T','2008-11-15','Calle Calvar 1','666 666 666', 1),
  (17,'Aron','Martinez',NULL,'33334444R','2008-11-16','Calle Pilar 8771','777 777 777', 2),
  (18,'Marcos','Antepazo','Ferradas','55556666Y','2008-11-17','Calle Santarosa 87','888 888 888', 3),
  (19,'Alejandro','Perez',NULL,'77778888Q','2008-11-18','Calle Eduardo Chaves 13','999 999 999', 4),
  (20,'Javi','Pucelas','Pereira','99998765S','2008-11-19','Calle Piñeiro 45','111 999 555', 5),
  (21,'Nerea','Santos',NULL,'66778899F','2007-01-05','Rua do Regueiro 15','600 000 001', 6),
  (22,'Adrian','Gomez','Paz','77889900G','2007-02-06','Rua do Regueiro 15','600 000 002', 7),
  (23,'Lucia','Rodriguez',NULL,'88990011I','2007-03-07','Rua do Regueiro 15','600 000 003', 8),
  (24,'Pablo','Alvarez','Seoane','99001122J','2007-04-08','Rua do Regueiro 15','600 000 004', 9),
  (25,'Sara','Prieto',NULL,'10101010K','2007-05-09','Rua do Regueiro 15','600 000 005', 10),
  (26, 'Diego','Vazquez',NULL,'20202020L','2007-06-10','Calle Calvar 22','600 000 006',11),
  (27,'Ainhoa','Crespo','Lage','30303030M','2007-07-11','Calle Calvar 23','600 000 007', 12),
  (28, 'Izan','Nogueira',NULL,'40404040N','2007-08-12','Calle Calvar 24','600 000 008',13),
  (29,'Carla','Souto','Pita','50505050O','2007-09-13','Calle Calvar 25','600 000 009', 14),
  (30,'Eric','Vidal',NULL,'60606060R','2007-10-14','Calle Calvar 26','600 000 010', 15);

--------------------------------------------------
-- 5) Tests (15)
INSERT INTO tests(cantidad_preguntas, duracion_max_minutos, tema, dispositivo) VALUES
  (25,25,'Luces','Movil'),
  (30,20,'Carroceria','Ordenador'),
  (17,30,'Actuación en accidente','Tablet_auto'),
  (10,12,'Emergencias','Movil'),
  (22,27,'Mantenimiento','PC'),
  (20,20,'Señales','Movil'),
  (15,15,'Prioridad de paso','Tablet_auto'),
  (18,22,'Velocidades','Ordenador'),
  (12,10,'Documentación','Movil'),
  (28,30,'Conducción eficiente','PC'),
  (16,18,'Alcohol y drogas','Movil'),
  (24,25,'Adelantamientos','Tablet_auto'),
  (14,14,'Intersecciones','Ordenador'),
  (26,28,'Túneles','PC'),
  (19,21,'Meteorología','Movil');
--------------------------------------------------
-- 6) Exámenes prácticos (15)
INSERT INTO examenesP(direccion, duracion_aprox_minutos, tipo) VALUES
  ('Garcia Barbon',30,'B'),
  ('Sanjurjo Badia',26,'D'),
  ('Avd de Galicia',27,'A'),
  ('Calle Palmas',35,'T'),
  ('Rua San Xoan',31,'C'),
  ('Rua Venezuela',28,'B'),
  ('Gran Via',32,'B'),
  ('Rua Urzaiz',29,'A'),
  ('Plaza España',34,'C'),
  ('Travesia de Vigo',30,'D'),
  ('Rua Aragon',27,'E'),
  ('Rua Barcelona',33,'B'),
  ('Rua Zamora',25,'A'),
  ('Rua Bolivia',36,'T'),
  ('Rua Coruña',28,'C');

--------------------------------------------------
-- 7) Exámenes teóricos (15)
INSERT INTO examenesT(direccion, cantidad_preguntas, duracion_max_minutos, tipo) VALUES
  ('Rua do Regueiro 15',30,30,'A'),
  ('Rua do Regueiro 15',30,40,'B'),
  ('Rua do Regueiro 15',30,25,'T'),
  ('Rua do Regueiro 15',30,21,'C'),
  ('Rua do Regueiro 15',30,17,'D'),
  ('Rua do Regueiro 15',25,25,'B'),
  ('Rua do Regueiro 15',20,20,'A'),
  ('Rua do Regueiro 15',35,35,'C'),
  ('Rua do Regueiro 15',40,45,'D'),
  ('Rua do Regueiro 15',15,15,'E'),
  ('Rua do Regueiro 15',10,12,'T'),
  ('Rua do Regueiro 15',28,30,'B'),
  ('Rua do Regueiro 15',26,28,'A'),
  ('Rua do Regueiro 15',32,35,'C'),
  ('Rua do Regueiro 15',22,25,'D');
--------------------------------------------------
-- 8) Prácticas (15)
INSERT INTO practicas(idestudiante, idempleado_instructor, idvehiculo, fecha, duracion_minutos, observaciones) VALUES
  (16,1, 1,'2025-12-01',60,'Circuito básico'),
  (16,2, 2,'2025-12-02',55,'Arranque en pendiente'),
  (18,3, 3,'2025-12-03',50,'Rotondas'),
  (19,4, 4,'2025-12-04',65,'Incorporaciones'),
  (21,5, 5,'2025-12-05',45,'Señalización'),
  (21,6, 6,'2025-12-06',60,'Maniobras'),
  (22,7, 7,'2025-12-07',70,'Autovía'),
  (23,8, 8,'2025-12-08',55,'Ciudad'),
  (25,9, 9,'2025-12-09',50,'Estacionamiento'),
  (25,10,10,'2025-12-10',65,'Conducción nocturna'),
  (26,11,11,'2025-12-11',60,'Glorietas'),
  (27,12,12,'2025-12-12',45,'Cambio de carril'),
  (28,13,13,'2025-12-13',75,'Autopista'),
  (29,14,14,'2025-12-14',50,'Cruces'),
  (30,15,15,'2025-12-15',55,'Repaso general');

--------------------------------------------------

-- 9) Notas de tests (15)
-- Usamos (idtest = 1-15) y (idestudiante = 16-30) 1 a 1, fechas distintas.
INSERT INTO notas_tests(idtest, idestudiante, aprobado, fecha, duracion_minutos, num_fallos) VALUES
  (1, 16, TRUE, '2025-12-10', 20, 1),
  (2, 17, TRUE, '2025-12-11', 18, 0),
  (3, 18, FALSE,'2025-12-12', 25, 7),
  (4, 19, FALSE,'2025-12-13', 15, 8),
  (5, 20, TRUE, '2025-12-14', 30, 2),
  (6, 21, TRUE, '2025-12-15', 19, 1),
  (7, 22, FALSE,'2025-12-16', 14, 5),
  (8, 23, TRUE, '2025-12-17', 21, 2),
  (9, 24, TRUE, '2025-12-18', 10, 0),
  (10,25, FALSE,'2025-12-19', 29, 6),
  (11,26, TRUE, '2025-12-20', 17, 1),
  (12,27, TRUE, '2025-12-21', 23, 2),
  (13,28, FALSE,'2025-12-22', 13, 4),
  (14,29, TRUE, '2025-12-23', 26, 2),
  (15,30, TRUE, '2025-12-24', 20, 1);

INSERT INTO notas_examenP VALUES
(1,16,11,1,26,TRUE,'2025-12-10',1),
(2,17,12,2,28,TRUE,'2025-12-11',0),
(3,18,13,3,37,FALSE,'2025-12-12',7),
(4,19,14,4,35,FALSE,'2025-12-13',8),
(5,20,15,5,27,TRUE,'2025-12-14',2),
(6,21,11,6,30,TRUE,'2025-12-15',1),
(7,22,12,7,32,FALSE,'2025-12-16',4),
(8,23,13,8,29,TRUE,'2025-12-17',2),
(9,24,14,9,34,TRUE,'2025-12-18',1),
(10,25,15,10,30,FALSE,'2025-12-19',5),
(11,26,11,1,27,TRUE,'2025-12-20',2),
(12,27,12,2,33,TRUE,'2025-12-21',1),
(13,28,13,3,25,FALSE,'2025-12-22',6),
(14,29,14,4,36,TRUE,'2025-12-23',2),
(15,30,15,5,28,TRUE,'2025-12-24',1);



-- 11) Notas de examen teórico (15)
INSERT INTO notas_examenT(idexamenT, idestudiante, fecha, duracion_minutos, num_aciertos) VALUES
  (1, 16, '2025-12-10', 26, 28),
  (2, 17, '2025-12-11', 28, 30),
  (3, 18, '2025-12-12', 25, 18),
  (4, 19, '2025-12-13', 21, 16),
  (5, 20, '2025-12-14', 17, 27),
  (6, 21, '2025-12-15', 20, 22),
  (7, 22, '2025-12-16', 19, 15),
  (8, 23, '2025-12-17', 24, 30),
  (9, 24, '2025-12-18', 30, 33),
  (10,25, '2025-12-19', 15, 10),
  (11,26, '2025-12-20', 12, 9),
  (12,27, '2025-12-21', 28, 26),
  (13,28, '2025-12-22', 29, 20),
  (14,29, '2025-12-23', 35, 30),
  (15,30, '2025-12-24', 25, 21);




  
















