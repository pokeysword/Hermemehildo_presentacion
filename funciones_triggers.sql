-- ===========================================================
-- FUNCIONES, PROCEDIMIENTO Y TRIGGERS - Autoescuela
-- PL/pgSQL - Nivel introductorio
-- ===========================================================
-- NOTA: Se usa "FROM ONLY personas" en algunas consultas para
-- evitar filas duplicadas que aparecen por herencia de tablas
-- (empleados y estudiantes heredan de personas en este modelo).
-- ===========================================================


-- ===========================================================
-- FUNCIÓN 1: total_minutos_estudiante
-- ===========================================================
-- ¿Qué hace?
--   Recibe el ID de un estudiante y devuelve cuántos minutos
--   de prácticas tiene acumulados en total.
--
-- ¿Por qué es útil?
--   Los profesores pueden comprobar de un vistazo si un alumno
--   tiene suficientes horas de conducción antes de presentarse
--   al examen práctico, sin tener que hacer cuentas a mano.
-- ===========================================================

CREATE OR REPLACE FUNCTION total_minutos_estudiante(p_idestudiante INT)
RETURNS INT AS $$
DECLARE
    v_nombre VARCHAR(60);  -- nombre del estudiante encontrado
    v_total  INT := 0;     -- acumulador de minutos (empieza en 0)
BEGIN
    -- Buscamos el nombre en personas.
    -- STRICT hace que se lance NO_DATA_FOUND si no hay resultados.
    SELECT nombre INTO STRICT v_nombre
    FROM ONLY personas
    WHERE idpersona = p_idestudiante;

    -- Sumamos los minutos de todas sus prácticas.
    -- COALESCE convierte NULL a 0 si no tiene ninguna práctica.
    SELECT COALESCE(SUM(duracion_minutos), 0) INTO v_total
    FROM practicas
    WHERE idestudiante = p_idestudiante;

    -- Mostramos un aviso distinto según el total acumulado
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

-- ----------------------------------------------------------------
-- EJEMPLOS DE LLAMADA - Función 1
-- ----------------------------------------------------------------

-- EJEMPLO 1: Estudiante con 2 prácticas (ID 16 = Sebas, 60+55 = 115 min)
-- Resultado esperado: aviso "lleva 115 min. Necesita más prácticas."
-- y el valor 115 como resultado de la función.
SELECT total_minutos_estudiante(16);

-- EJEMPLO 2: Estudiante sin ninguna práctica (ID 17 = Aron Martinez, 0 min)
-- Resultado esperado: aviso "no tiene prácticas registradas todavía."
-- y el valor 0.
SELECT total_minutos_estudiante(17);

-- EJEMPLO 3: ID que no existe en la base de datos
-- Resultado esperado: excepción NO_DATA_FOUND con mensaje de error.
SELECT total_minutos_estudiante(999);


-- ===========================================================
-- FUNCIÓN 2: practicas_del_instructor
-- ===========================================================
-- ¿Qué hace?
--   Devuelve una tabla con el listado de prácticas que ha
--   impartido un instructor: el nombre del estudiante, la
--   fecha, la duración y la matrícula del vehículo.
--
-- ¿Por qué es útil?
--   Permite ver el historial de clases de cada profesor de
--   forma clara, sin tener que escribir JOINs manualmente
--   cada vez que se necesite esta información.
--
-- Demuestra: cursor explícito con múltiples JOINs, bucle
-- LOOP, RETURN NEXT, variables locales y RAISE NOTICE.
-- ===========================================================

CREATE OR REPLACE FUNCTION practicas_del_instructor(p_idinstructor INT)
RETURNS TABLE (
    estudiante   TEXT,
    fecha        DATE,
    duracion_min INT,
    matricula    VARCHAR
) AS $$
DECLARE
    -- Cursor con un JOIN a personas (para el nombre del estudiante)
    -- y otro JOIN a vehiculos (para la matrícula).
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

    v_fila        RECORD;       -- almacena la fila actual del cursor
    v_nombre_inst VARCHAR(60);  -- nombre del instructor
    v_contador    INT := 0;     -- cuenta cuántas prácticas se han encontrado
BEGIN
    -- Comprobamos que el instructor existe
    SELECT nombre INTO STRICT v_nombre_inst
    FROM ONLY personas
    WHERE idpersona = p_idinstructor;

    RAISE NOTICE 'Buscando prácticas de: %', v_nombre_inst;

    -- Abrimos el cursor y recorremos sus resultados con un bucle
    OPEN cur_practicas;
    LOOP
        FETCH cur_practicas INTO v_fila;
        EXIT WHEN NOT FOUND;   -- salimos del bucle cuando no quedan filas

        v_contador := v_contador + 1;

        -- Rellenamos las columnas de la tabla que devuelve la función
        estudiante   := v_fila.nombre_est;
        fecha        := v_fila.fecha;
        duracion_min := v_fila.duracion_minutos;
        matricula    := v_fila.matricula;

        RETURN NEXT;  -- devolvemos esta fila al resultado
    END LOOP;
    CLOSE cur_practicas;

    -- Mensaje final con el total encontrado
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

-- ----------------------------------------------------------------
-- EJEMPLOS DE LLAMADA - Función 2
-- ----------------------------------------------------------------

-- EJEMPLO 1: Instructor ID 1 (Anxo Curras) - tiene 1 práctica con Sebas
-- Resultado esperado: 1 fila con estudiante='Sebas Vazques', fecha='2025-12-01',
-- duracion_min=60, matricula='1111AAA'.
SELECT * FROM practicas_del_instructor(1);

-- EJEMPLO 2: Instructor ID 2 (Angel Mendez) - tiene 1 práctica con Sebas
-- Resultado esperado: 1 fila con fecha '2025-12-02', 55 minutos, matrícula '2222BBB'.
SELECT * FROM practicas_del_instructor(2);

-- EJEMPLO 3: ID que no existe → excepción NO_DATA_FOUND
SELECT * FROM practicas_del_instructor(999);


-- ===========================================================
-- PROCEDIMIENTO: registrar_practica
-- ===========================================================
-- ¿Qué hace?
--   Inserta una nueva práctica en la base de datos. El usuario
--   pasa el DNI del estudiante y la matrícula del vehículo,
--   y el procedimiento busca automáticamente sus IDs internos.
--
-- ¿Por qué es útil?
--   Facilita el registro de prácticas sin necesidad de conocer
--   los IDs de la base de datos. Además, valida que el
--   estudiante y el vehículo existan antes de insertar,
--   evitando errores manuales.
--
-- Demuestra: DML (INSERT), SELECT INTO STRICT, condicionales,
-- NO_DATA_FOUND, TOO_MANY_ROWS y OTHERS.
-- ===========================================================

CREATE OR REPLACE PROCEDURE registrar_practica(
    p_dni        VARCHAR(9),   -- DNI del estudiante
    p_matricula  VARCHAR(7),   -- matrícula del vehículo
    p_fecha      DATE,         -- fecha de la práctica
    p_duracion   INT,          -- duración en minutos
    p_obs        TEXT DEFAULT NULL  -- observaciones (opcional)
)
AS $$
DECLARE
    v_idestudiante INT;          -- ID del estudiante que buscamos
    v_idvehiculo   INT;          -- ID del vehículo que buscamos
    v_nombre       VARCHAR(60);  -- nombre del estudiante
BEGIN
    -- Buscamos al estudiante por su DNI.
    -- Si no existe: NO_DATA_FOUND. Si hay más de uno: TOO_MANY_ROWS.
    SELECT idpersona, nombre INTO STRICT v_idestudiante, v_nombre
    FROM ONLY personas
    WHERE dni = p_dni;

    -- Buscamos el vehículo por su matrícula.
    SELECT idvehiculo INTO STRICT v_idvehiculo
    FROM vehiculos
    WHERE matricula = p_matricula;

    -- Validación extra: la duración debe ser positiva
    IF p_duracion <= 0 THEN
        RAISE EXCEPTION 'La duración debe ser mayor que 0 minutos.';
    END IF;

    -- Insertamos la nueva práctica con los IDs encontrados
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

-- ----------------------------------------------------------------
-- EJEMPLOS DE LLAMADA - Procedimiento
-- ----------------------------------------------------------------

-- EJEMPLO 1: Llamada correcta
-- Aron Martinez (DNI 33334444R) practica con el vehículo 2222BBB
CALL registrar_practica('33334444R', '2222BBB', '2026-01-10', 60, 'Repaso de maniobras');
-- Comprobamos que se insertó:
SELECT idestudiante, fecha, duracion_minutos, observaciones
FROM practicas
WHERE idestudiante = 17;

-- EJEMPLO 2: DNI que no existe → excepción NO_DATA_FOUND
CALL registrar_practica('99999999Z', '1111AAA', '2026-01-11', 45, NULL);

-- EJEMPLO 3: Matrícula que no existe → excepción NO_DATA_FOUND
CALL registrar_practica('33334444R', 'ZZZZZZZ', '2026-01-12', 50, NULL);


-- ===========================================================
-- TABLA AUXILIAR PARA EL TRIGGER 2
-- ===========================================================
-- Creamos una tabla de registro (log) donde el trigger 2
-- guardará los cambios que se hagan en la tabla practicas.

CREATE TABLE IF NOT EXISTS log_practicas (
    idlog             SERIAL PRIMARY KEY,
    idestudiante      INT,
    fecha_cambio      TIMESTAMP DEFAULT NOW(),
    tipo_operacion    VARCHAR(10),    -- 'INSERT' o 'UPDATE'
    duracion_anterior INT,            -- NULL cuando es una inserción
    duracion_nueva    INT,
    descripcion       TEXT
);


-- ===========================================================
-- TRIGGER 1: trg_validar_instructor
-- ===========================================================
-- ¿Qué lo desencadena?
--   Se activa ANTES de cada INSERT en la tabla practicas,
--   una fila a la vez (FOR EACH ROW).
--
-- ¿Qué hace?
--   Comprueba que, si se indica un instructor
--   (idempleado_instructor NOT NULL), ese ID pertenezca a
--   alguien que está en la tabla empleados. Si no es así,
--   cancela la inserción lanzando una excepción.
--
-- ¿Por qué es útil?
--   La clave foránea de practicas solo verifica que el ID
--   exista en personas, pero no que sea un empleado. Este
--   trigger añade esa validación extra, evitando que se
--   registre como instructor a un estudiante o a alguien
--   externo que no trabaje en la autoescuela.
--
-- Demuestra: BEFORE, FOR EACH ROW, NEW, condicional IF,
-- RETURN NEW (permite la operación) vs RAISE EXCEPTION
-- (la cancela).
-- ===========================================================

CREATE OR REPLACE FUNCTION fn_validar_instructor()
RETURNS TRIGGER AS $$
DECLARE
    v_es_empleado INT;  -- número de coincidencias en empleados (0 o 1)
BEGIN
    -- Si no se indicó instructor, no hay nada que comprobar
    IF NEW.idempleado_instructor IS NULL THEN
        RETURN NEW;  -- dejamos pasar la inserción tal cual
    END IF;

    -- Buscamos si el ID indicado pertenece a un empleado
    SELECT COUNT(*) INTO v_es_empleado
    FROM empleados
    WHERE idpersona = NEW.idempleado_instructor;

    -- Si no es empleado, cancelamos la inserción
    IF v_es_empleado = 0 THEN
        RAISE EXCEPTION
            'La persona con ID % no es un empleado de la autoescuela.',
            NEW.idempleado_instructor;
    END IF;

    RETURN NEW;  -- todo correcto: devolvemos NEW para continuar con el INSERT
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_instructor
BEFORE INSERT ON practicas
FOR EACH ROW
EXECUTE FUNCTION fn_validar_instructor();

-- ----------------------------------------------------------------
-- EJEMPLOS DE LANZAMIENTO - Trigger 1
-- ----------------------------------------------------------------

-- EJEMPLO 1: Inserción válida
-- El instructor ID 3 (Xurxo Fisterra) sí es empleado → el trigger
-- comprueba, no encuentra problemas, y devuelve NEW. El INSERT se realiza.
INSERT INTO practicas (idestudiante, idempleado_instructor, idvehiculo, fecha, duracion_minutos)
VALUES (20, 3, 3, '2026-01-15', 55);
-- Comprobamos que se insertó:
SELECT * FROM practicas WHERE idestudiante = 20 AND fecha = '2026-01-15';

-- EJEMPLO 2: Inserción inválida
-- El ID 16 corresponde a Sebas Vazques, que es estudiante, no empleado.
-- El trigger detecta que no está en empleados y lanza la excepción,
-- por lo que el INSERT queda cancelado.
INSERT INTO practicas (idestudiante, idempleado_instructor, idvehiculo, fecha, duracion_minutos)
VALUES (18, 16, 4, '2026-01-16', 60);

-- EJEMPLO 3: Inserción sin instructor (NULL)
-- El trigger comprueba que idempleado_instructor IS NULL y devuelve
-- NEW directamente sin hacer ninguna validación. El INSERT se realiza.
INSERT INTO practicas (idestudiante, idempleado_instructor, idvehiculo, fecha, duracion_minutos)
VALUES (24, NULL, 5, '2026-01-17', 45);
-- Verificamos:
SELECT * FROM practicas WHERE idestudiante = 24 AND fecha = '2026-01-17';

-- ----------------------------------------------------------------
-- ¿Cómo desactivar el trigger 1?
-- ----------------------------------------------------------------
-- Para desactivarlo temporalmente (por ejemplo, al cargar datos masivos):
--   ALTER TABLE practicas DISABLE TRIGGER trg_validar_instructor;
-- Para volver a activarlo:
--   ALTER TABLE practicas ENABLE TRIGGER trg_validar_instructor;
-- Para desactivar TODOS los triggers de la tabla de golpe:
--   ALTER TABLE practicas DISABLE TRIGGER ALL;
-- Para reactivarlos todos:
--   ALTER TABLE practicas ENABLE TRIGGER ALL;


-- ===========================================================
-- TRIGGER 2: trg_log_practicas
-- ===========================================================
-- ¿Qué lo desencadena?
--   Se activa DESPUÉS de cada INSERT o UPDATE en practicas,
--   fila a fila (FOR EACH ROW).
--
-- ¿Qué hace?
--   - En un INSERT: guarda en log_practicas que se añadió
--     una nueva práctica y cuántos minutos tiene.
--   - En un UPDATE: solo guarda un registro si la duración
--     cambió (compara OLD.duracion_minutos con NEW.duracion_minutos).
--     Si solo cambiaron otros campos (p. ej. observaciones),
--     no escribe nada en el log.
--
-- ¿Por qué es útil?
--   Mantiene un historial de cambios en las prácticas. Así
--   se puede saber en cualquier momento cuándo se añadió
--   una clase o cuándo alguien modificó su duración.
--
-- Demuestra: AFTER, FOR EACH ROW, NEW, OLD, TG_OP,
-- RETURN NULL (en triggers AFTER el valor de retorno se ignora),
-- condicionales con TG_OP e IF...THEN.
--
-- NOTA sobre FOR EACH STATEMENT:
--   Si usáramos FOR EACH STATEMENT, el trigger se ejecutaría
--   una sola vez por sentencia SQL (sin importar cuántas filas
--   afecte) y no tendríamos acceso a NEW ni a OLD. En este caso
--   necesitamos los datos de cada fila, por eso usamos FOR EACH ROW.
-- ===========================================================

CREATE OR REPLACE FUNCTION fn_log_practicas()
RETURNS TRIGGER AS $$
BEGIN
    -- Cuando se inserta una nueva práctica
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_practicas (idestudiante, tipo_operacion, duracion_anterior, duracion_nueva, descripcion)
        VALUES (
            NEW.idestudiante,
            'INSERT',
            NULL,
            NEW.duracion_minutos,
            'Nueva práctica añadida. Fecha: ' || NEW.fecha
        );

    -- Cuando se actualiza una práctica existente
    ELSIF TG_OP = 'UPDATE' THEN
        -- Solo registramos el cambio si la duración fue modificada
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

    RETURN NULL;  -- en triggers AFTER el valor de retorno es ignorado; se devuelve NULL por convención
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_practicas
AFTER INSERT OR UPDATE ON practicas
FOR EACH ROW
EXECUTE FUNCTION fn_log_practicas();

-- ----------------------------------------------------------------
-- EJEMPLOS DE LANZAMIENTO - Trigger 2
-- ----------------------------------------------------------------

-- EJEMPLO 1: INSERT → el trigger crea un registro en log_practicas
INSERT INTO practicas (idestudiante, idvehiculo, fecha, duracion_minutos)
VALUES (26, 7, '2026-02-01', 70);
-- Verificamos que se creó el registro en el log:
SELECT * FROM log_practicas ORDER BY idlog DESC LIMIT 3;

-- EJEMPLO 2: UPDATE con cambio de duración → el trigger registra el cambio
UPDATE practicas
SET duracion_minutos = 90
WHERE idestudiante = 26 AND fecha = '2026-02-01';
-- Verificamos: debe haber una nueva entrada en el log con tipo 'UPDATE'
SELECT * FROM log_practicas ORDER BY idlog DESC LIMIT 3;

-- EJEMPLO 3: UPDATE sin cambio de duración → el trigger NO registra nada
UPDATE practicas
SET observaciones = 'Práctica revisada'
WHERE idestudiante = 26 AND fecha = '2026-02-01';
-- El log no cambia porque la duración sigue siendo la misma:
SELECT * FROM log_practicas ORDER BY idlog DESC LIMIT 3;

-- ----------------------------------------------------------------
-- ¿Cómo desactivar el trigger 2?
-- ----------------------------------------------------------------
--   ALTER TABLE practicas DISABLE TRIGGER trg_log_practicas;
--   ALTER TABLE practicas ENABLE  TRIGGER trg_log_practicas;
-- O para desactivar / activar todos los triggers de la tabla:
--   ALTER TABLE practicas DISABLE TRIGGER ALL;
--   ALTER TABLE practicas ENABLE  TRIGGER ALL;


-- ===========================================================
-- BACKUP - Cómo realizar una copia de seguridad completa
-- ===========================================================
--
-- El comando pg_dump genera un fichero que contiene todo lo
-- necesario para reconstruir la base de datos desde cero:
-- tablas, datos, vistas, funciones, procedimientos y triggers.
--
-- ---- CREAR EL BACKUP ----
--
-- Formato SQL plano (legible con cualquier editor de texto):
--
--   Windows (PowerShell o CMD):
--   pg_dump -U postgres -h localhost -d autoescuela > backup_autoescuela.sql
--
--   Linux / macOS:
--   pg_dump -U postgres -h localhost -d autoescuela > /tmp/backup_autoescuela.sql
--
-- Formato comprimido (recomendado para bases de datos grandes):
--
--   pg_dump -U postgres -h localhost -d autoescuela -F c -f backup_autoescuela.dump
--
-- Explicación de los parámetros:
--   -U postgres      → usuario de PostgreSQL con permisos suficientes
--   -h localhost     → dirección del servidor (o IP si está en otro equipo)
--   -d autoescuela   → nombre de la base de datos a copiar
--   -F c             → formato custom (comprimido, solo válido con -f)
--   -f fichero       → nombre del fichero de salida
--
-- ---- RESTAURAR EL BACKUP ----
--
-- Paso 1: Crear la base de datos destino (si no existe):
--   psql -U postgres -h localhost -c "CREATE DATABASE autoescuela_nueva;"
--
-- Paso 2a: Restaurar desde formato SQL plano:
--   psql -U postgres -h localhost -d autoescuela_nueva < backup_autoescuela.sql
--
-- Paso 2b: Restaurar desde formato comprimido:
--   pg_restore -U postgres -h localhost -d autoescuela_nueva backup_autoescuela.dump
--
-- ---- VERIFICACIÓN ----
-- Tras la restauración, para comprobar que todo se restauró sin errores,
-- conectarse a la base nueva y ejecutar:
--
--   \dt              → lista las tablas
--   \df              → lista las funciones y procedimientos
--   \dy              → lista los triggers (en versiones recientes)
--   SELECT COUNT(*) FROM practicas;    → comprobar datos
--   SELECT total_minutos_estudiante(16);  → comprobar que las funciones funcionan
--
-- ===========================================================
