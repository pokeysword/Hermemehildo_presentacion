--Marcar como aprobados (aprobado = TRUE) los tests de estudiantes que han hecho más de 1 práctica
UPDATE notas_tests nt
SET aprobado = TRUE
WHERE nt.idestudiante IN (
    SELECT pr.idestudiante
    FROM practicas pr
    GROUP BY pr.idestudiante
    HAVING COUNT(*) > 1
);

--Actualizar teléfonos de personas que: viven en “Rua” y tienen teléfono NULL o mal formateado
UPDATE personas
SET telefono = REGEXP_REPLACE(COALESCE(telefono, '000000000'), '[^0-9]', '', 'g')
WHERE direccion ILIKE '%Rua%'
AND (telefono IS NULL OR telefono !~ '^[0-9 ]+$');

--Eliminar notas de test con demasiados fallos (> 6)
DELETE FROM notas_tests
WHERE num_fallos > 6;


--Eliminar prácticas de estudiantes que han suspendido examen práctico
DELETE FROM practicas pr
USING notas_examenP nep
WHERE pr.idestudiante = nep.idestudiante
AND nep.aprobado = FALSE;

--8. TRANSACCIONES

--Bloquear prácticas de un estudiante mientras se revisan

BEGIN;

SELECT *
FROM practicas
WHERE idestudiante IN (
    SELECT idpersona FROM personas WHERE nombre = 'Sebas'
)
FOR UPDATE;

--Añadimos mas tiempo a la practica
UPDATE practicas
SET duracion_minutos = duracion_minutos + 5
WHERE idestudiante IN (
    SELECT idpersona FROM personas WHERE nombre = 'Sebas'
);

COMMIT;

--Permitir lecturas pero no modificaciones

--Usuario 1
BEGIN;
LOCK TABLE practicas IN SHARE MODE;

--Usuario 2
SELECT * FROM practicas; --permitido
UPDATE practicas SET duracion_minutos = 10; --bloqueado

--Usuario 1
ROLLBACK;


--Bloquear completamente la tabla

--Usuario 1
BEGIN;
LOCK TABLE practicas IN ACCESS EXCLUSIVE MODE;

--Usuario 2
SELECT * FROM practicas; --bloqueado

--Usuario 1
COMMIT;



/*Vistas */
--Unir datos personales + vehículo

CREATE VIEW vista_estudiantes AS
SELECT DISTINCT(p.nombre),p.apellido1,v.marca,v.modelo
FROM estudiantes e
JOIN personas p ON e.idpersona = p.idpersona
JOIN vehiculos v ON e.idvehiculo = v.idvehiculo;


SELECT * FROM vista_estudiantes;


--Ver resultados de tests con datos del alumno

CREATE VIEW vista_resultados_tests AS
SELECT DISTINCT (p.nombre),p.apellido1,nt.aprobado,nt.num_fallos
FROM notas_tests nt
JOIN personas p ON nt.idestudiante = p.idpersona;

SELECT * 
FROM vista_resultados_tests
WHERE aprobado = TRUE;




