-- Autoescuela (PostgreSQL)
-- Modelo con Persona como entidad base, extensiones Estudiante/Empleado,
-- entidad Practica y examinador como persona (no necesariamente empleado).
-- Tipos de duración: se usan minutos como entero (duracion_minutos).

DROP TABLE IF EXISTS notas_examenT CASCADE;
DROP TABLE IF EXISTS notas_examenP CASCADE;
DROP TABLE IF EXISTS notas_tests CASCADE;
DROP TABLE IF EXISTS practicas CASCADE;
DROP TABLE IF EXISTS estudiantes CASCADE;
DROP TABLE IF EXISTS empleados CASCADE;
DROP TABLE IF EXISTS personas CASCADE;
DROP TABLE IF EXISTS examenesT CASCADE;
DROP TABLE IF EXISTS examenesP CASCADE;
DROP TABLE IF EXISTS vehiculos CASCADE;
DROP TABLE IF EXISTS tests CASCADE;
DROP TYPE IF EXISTS tipo_enum;

-- Tipos
CREATE TYPE tipo_enum AS ENUM ('B','A','C','D','E','T');

-- Entidades base
CREATE TABLE personas (
  idpersona SERIAL PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  apellido1 VARCHAR(60) NOT NULL,
  apellido2 VARCHAR(60),
  dni VARCHAR(9) NOT NULL UNIQUE,
  fecha_nac DATE NOT NULL,
  direccion TEXT,
  telefono TEXT NOT NULL
);

-- Empleado 
CREATE TABLE empleados (
  telefonos_empresa TEXT[] DEFAULT ARRAY[]::TEXT[]
) INHERITS (personas);

-- Vehículos
CREATE TABLE vehiculos (
  idvehiculo SERIAL PRIMARY KEY,
  matricula VARCHAR(7) NOT NULL UNIQUE,
  modelo VARCHAR(30),
  marca VARCHAR(30),
  color VARCHAR(30)
);

-- Estudiante 
CREATE TABLE estudiantes (
  idvehiculo INT NOT NULL REFERENCES vehiculos(idvehiculo) ON DELETE RESTRICT
) INHERITS (personas);

-- Definición de tests
CREATE TABLE tests (
  idtest SERIAL PRIMARY KEY,
  cantidad_preguntas INT NOT NULL CHECK (cantidad_preguntas > 0),
  duracion_max_minutos INT NOT NULL CHECK (duracion_max_minutos > 0),
  tema TEXT NOT NULL,
  dispositivo VARCHAR(50)
);

-- Definición de exámenes (práctico / teórico)
CREATE TABLE examenesP (
  idexamenP SERIAL PRIMARY KEY,
  direccion TEXT NOT NULL,
  duracion_aprox_minutos INT NOT NULL CHECK (duracion_aprox_minutos > 0),
  tipo tipo_enum NOT NULL
);

CREATE TABLE examenesT (
  idexamenT SERIAL PRIMARY KEY,
  direccion TEXT NOT NULL,
  cantidad_preguntas INT NOT NULL CHECK (cantidad_preguntas > 0),
  duracion_max_minutos INT NOT NULL CHECK (duracion_max_minutos > 0),
  tipo tipo_enum NOT NULL
);

-- Prácticas: 
CREATE TABLE practicas (
  idpractica SERIAL PRIMARY KEY,
  idestudiante INT REFERENCES personas(idpersona) ON DELETE CASCADE,
  idempleado_instructor INT REFERENCES personas(idpersona) ON DELETE SET NULL,
  idvehiculo INT REFERENCES vehiculos(idvehiculo) ON DELETE SET NULL,
  fecha DATE NOT NULL,
  duracion_minutos INT NOT NULL CHECK (duracion_minutos > 0),
  observaciones TEXT
);

-- Resultados (intentos) de tests
CREATE TABLE notas_tests (
  idtest INT REFERENCES tests(idtest) ON DELETE CASCADE,
  idestudiante INT REFERENCES personas(idpersona) ON DELETE CASCADE,
  aprobado BOOLEAN NOT NULL,
  fecha DATE NOT NULL,
  duracion_minutos INT NOT NULL CHECK (duracion_minutos > 0),
  num_fallos INT NOT NULL CHECK (num_fallos >= 0),
  PRIMARY KEY (idtest, idestudiante, fecha)
);

-- Resultados(intentos) de examen práctico
-- Examinador es una persona , profesor es empleado.
CREATE TABLE notas_examenP (
  idexamenP INT REFERENCES examenesP(idexamenP) ON DELETE CASCADE,
  idestudiante INT REFERENCES personas(idpersona) ON DELETE CASCADE,
  idexaminador INT NOT NULL REFERENCES personas(idpersona) ON DELETE RESTRICT,
  idprofesor INT NOT NULL REFERENCES personas(idpersona) ON DELETE RESTRICT,
  duracion_minutos INT NOT NULL CHECK (duracion_minutos > 0),
  aprobado BOOLEAN NOT NULL,
  fecha DATE NOT NULL,
  num_faltas INT NOT NULL CHECK (num_faltas >= 0),
  PRIMARY KEY (idexamenP, idestudiante, fecha)
);

-- Resultados (intentos) de examen teórico:
-- Se guarda fecha y "num_aciertos" 
CREATE TABLE notas_examenT (
  idexamenT INT REFERENCES examenesT(idexamenT) ON DELETE CASCADE,
  idestudiante INT REFERENCES personas(idpersona) ON DELETE CASCADE,
  fecha DATE NOT NULL,
  duracion_minutos INT NOT NULL CHECK (duracion_minutos > 0),
  num_aciertos INT NOT NULL CHECK (num_aciertos >= 0),
  PRIMARY KEY (idexamenT, idestudiante, fecha)
);

-- Índices útiles 
CREATE INDEX idx_practicas_estudiante ON practicas(idestudiante);
CREATE INDEX idx_notasT_estudiante ON notas_examenT(idestudiante);
CREATE INDEX idx_notasP_estudiante ON notas_examenP(idestudiante);
CREATE INDEX idx_notas_tests_estudiante ON notas_tests(idestudiante);

ALTER TABLE empleados
ADD COLUMN idjefe INT REFERENCES personas(idpersona);
/*Puede tener mas de 1 telefono (telefonos de empresa)*/
ALTER TABLE empleados
ALTER COLUMN telefonos_empresa TYPE TEXT[]
/*convertimos todos los datos existentes a TEXT[]*/
USING ARRAY[telefonos_empresa];
/*hace que los dnis introducidos sean unicos */
ALTER TABLE personas
ADD CONSTRAINT dni_unico UNIQUE (dni);

ALTER TABLE estudiantes
ADD CONSTRAINT dni_unico_estudiantes UNIQUE (dni);

ALTER TABLE empleados
ADD CONSTRAINT dni_unico_empleados UNIQUE (dni);
/*chequea que el id del examinador nosea el mismo que el profesor*/
ALTER TABLE notas_examenP
ADD CONSTRAINT chk_examinador_profesor_distintos
CHECK (idexaminador <> idprofesor);
