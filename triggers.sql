
-- TRIGGER 1: trg_validar_instructor

CREATE OR REPLACE FUNCTION fn_validar_instructor()
RETURNS TRIGGER AS $$
DECLARE
    v_es_empleado INT; 
BEGIN
    IF NEW.idempleado_instructor IS NULL THEN
        RETURN NEW; 
    END IF;

    SELECT COUNT(*) INTO v_es_empleado
    FROM empleados
    WHERE idpersona = NEW.idempleado_instructor;

    IF v_es_empleado = 0 THEN
        RAISE EXCEPTION
            'La persona con ID % no es un empleado de la autoescuela.',
            NEW.idempleado_instructor;
    END IF;

    RETURN NEW;  
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_instructor
BEFORE INSERT ON practicas
FOR EACH ROW
EXECUTE FUNCTION fn_validar_instructor();


INSERT INTO practicas (idestudiante, idempleado_instructor, idvehiculo, fecha, duracion_minutos)
VALUES (20, 3, 3, '2026-01-15', 55);
SELECT * FROM practicas WHERE idestudiante = 20 AND fecha = '2026-01-15';

INSERT INTO practicas (idestudiante, idempleado_instructor, idvehiculo, fecha, duracion_minutos)
VALUES (18, 16, 4, '2026-01-16', 60);

INSERT INTO practicas (idestudiante, idempleado_instructor, idvehiculo, fecha, duracion_minutos)
VALUES (24, NULL, 5, '2026-01-17', 45);
SELECT * FROM practicas WHERE idestudiante = 24 AND fecha = '2026-01-17';


-- TRIGGER 2: 


-- TABLA PARA EL TRIGGER 2


CREATE TABLE IF NOT EXISTS log_practicas (
    idlog             SERIAL PRIMARY KEY,
    idestudiante      INT,
    fecha_cambio      TIMESTAMP DEFAULT NOW(),
    tipo_operacion    VARCHAR(10),    
    duracion_anterior INT,           
    duracion_nueva    INT,
    descripcion       TEXT
);


CREATE OR REPLACE FUNCTION fn_log_practicas()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_practicas (idestudiante, tipo_operacion, duracion_anterior, duracion_nueva, descripcion)
        VALUES (
            NEW.idestudiante,
            'INSERT',
            NULL,
            NEW.duracion_minutos,
            'Nueva práctica añadida. Fecha: ' || NEW.fecha
        );

    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.duracion_minutos <> NEW.duracion_minutos THEN
            INSERT INTO log_practicas (idestudiante, tipo_operacion, duracion_anterior, duracion_nueva, descripcion)
            VALUES (
                NEW.idestudiante,
                'UPDATE',
                OLD.duracion_minutos,
                NEW.duracion_minutos,
                'Duración cambiada de ' || OLD.duracion_minutos || ' a ' || NEW.duracion_minutos || ' min'
            );
        END IF;
    END IF;

    RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_practicas
AFTER INSERT OR UPDATE ON practicas
FOR EACH ROW
EXECUTE FUNCTION fn_log_practicas();



INSERT INTO practicas (idestudiante, idvehiculo, fecha, duracion_minutos)
VALUES (26, 7, '2026-02-01', 70);
SELECT * FROM log_practicas ORDER BY idlog DESC LIMIT 3;

UPDATE practicas
SET duracion_minutos = 90
WHERE idestudiante = 26 AND fecha = '2026-02-01';
SELECT * FROM log_practicas ORDER BY idlog DESC LIMIT 3;


UPDATE practicas
SET observaciones = 'Práctica revisada'
WHERE idestudiante = 26 AND fecha = '2026-02-01';
SELECT * FROM log_practicas ORDER BY idlog DESC LIMIT 3;