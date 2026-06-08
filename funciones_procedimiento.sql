--Función 1

CREATE OR REPLACE FUNCTION total_minutos_estudiante(p_idestudiante INT)
RETURNS INT AS $$
DECLARE
    v_nombre VARCHAR(60);  
    v_total  INT := 0;    
BEGIN
   
    SELECT nombre INTO STRICT v_nombre
    FROM ONLY personas
    WHERE idpersona = p_idestudiante;

    SELECT COALESCE(SUM(duracion_minutos), 0) INTO v_total
    FROM practicas
    WHERE idestudiante = p_idestudiante;

    IF v_total = 0 THEN
        RAISE NOTICE '% no tiene prácticas registradas todavía.', v_nombre;
    ELSIF v_total < 200 THEN
        RAISE NOTICE '% lleva % min. Todavía necesita más prácticas.', v_nombre, v_total;
    ELSE
        RAISE NOTICE '% lleva % min. ¡Puede presentarse al examen práctico!', v_nombre, v_total;
    END IF;

    RETURN v_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'No existe ningún estudiante con ID %.', p_idestudiante;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inesperado: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;


SELECT total_minutos_estudiante(16);
SELECT total_minutos_estudiante(17);
SELECT total_minutos_estudiante(999);



-- Función 2

CREATE OR REPLACE FUNCTION practicas_del_instructor(p_idinstructor INT)
RETURNS TABLE (
    estudiante   TEXT,
    fecha        DATE,
    duracion_min INT,
    matricula    VARCHAR
) AS $$
DECLARE
    cur_practicas CURSOR FOR
        SELECT
            (per.nombre || ' ' || per.apellido1)  AS nombre_est,
            prac.fecha,
            prac.duracion_minutos,
            veh.matricula
        FROM practicas prac
        JOIN ONLY personas per  ON per.idpersona  = prac.idestudiante
        LEFT JOIN vehiculos veh ON veh.idvehiculo = prac.idvehiculo
        WHERE prac.idempleado_instructor = p_idinstructor
        ORDER BY prac.fecha;

    v_fila        RECORD;       
    v_nombre_inst VARCHAR(60); 
    v_contador    INT := 0;     
BEGIN
    SELECT nombre INTO STRICT v_nombre_inst
    FROM ONLY personas
    WHERE idpersona = p_idinstructor;

    RAISE NOTICE 'Buscando prácticas de: %', v_nombre_inst;

    OPEN cur_practicas;
    LOOP
        FETCH cur_practicas INTO v_fila;
        EXIT WHEN NOT FOUND; 

        v_contador := v_contador + 1;
        estudiante   := v_fila.nombre_est;
        fecha        := v_fila.fecha;
        duracion_min := v_fila.duracion_minutos;
        matricula    := v_fila.matricula;

        RETURN NEXT; 
    END LOOP;
    CLOSE cur_practicas;

    IF v_contador = 0 THEN
        RAISE NOTICE '% aún no tiene prácticas registradas.', v_nombre_inst;
    ELSE
        RAISE NOTICE 'Total de prácticas encontradas: %', v_contador;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'No existe ningún instructor con ID %.', p_idinstructor;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inesperado: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM practicas_del_instructor(1);
SELECT * FROM practicas_del_instructor(2);
SELECT * FROM practicas_del_instructor(999);



-- Procedimiento

CREATE OR REPLACE PROCEDURE registrar_practica(
    p_dni        VARCHAR(9),  
    p_matricula  VARCHAR(7),  
    p_fecha      DATE,         
    p_duracion   INT,         
    p_obs        TEXT DEFAULT NULL  
)
AS $$
DECLARE
    v_idestudiante INT;         
    v_idvehiculo   INT;          
    v_nombre       VARCHAR(60);  
BEGIN
    SELECT idpersona, nombre INTO STRICT v_idestudiante, v_nombre
    FROM ONLY personas
    WHERE dni = p_dni;

    SELECT idvehiculo INTO STRICT v_idvehiculo
    FROM vehiculos
    WHERE matricula = p_matricula;

    IF p_duracion <= 0 THEN
        RAISE EXCEPTION 'La duración debe ser mayor que 0 minutos.';
    END IF;

    INSERT INTO practicas (idestudiante, idvehiculo, fecha, duracion_minutos, observaciones)
    VALUES (v_idestudiante, v_idvehiculo, p_fecha, p_duracion, p_obs);

    RAISE NOTICE 'Práctica de % min registrada para % el %.', p_duracion, v_nombre, p_fecha;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION
            'No se encontró al estudiante con DNI "%" o al vehículo con matrícula "%".',
            p_dni, p_matricula;
    WHEN TOO_MANY_ROWS THEN
        RAISE EXCEPTION
            'El DNI "%" aparece duplicado en la base de datos. Contacta con el administrador.',
            p_dni;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al registrar la práctica: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

CALL registrar_practica('33334444R', '2222BBB', '2026-01-10', 60, 'Repaso de maniobras');

SELECT idestudiante, fecha, duracion_minutos, observaciones
FROM practicas
WHERE idestudiante = 17;

CALL registrar_practica('99999999Z', '1111AAA', '2026-01-11', 45, NULL);
CALL registrar_practica('33334444R', 'ZZZZZZZ', '2026-01-12', 50, NULL);