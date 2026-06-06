Funciones
	1.- 
¿Qué hace?
Recibe el ID de un estudiante y devuelve cuántos minutos de prácticas tiene acumulados en total.
¿Por qué es útil?
Los profesores pueden comprobar de un vistazo si un alumno tiene suficientes horas de conducción antes de presentarse al examen práctico, sin tener que hacer cuentas a mano.

2.- 
¿Qué hace?
Devuelve una tabla con el listado de prácticas que ha impartido un instructor: el nombre del estudiante, la fecha, la duración y la matrícula del vehículo.

¿Por qué es útil?
Permite ver el historial de clases de cada profesor de forma clara, sin tener que escribir JOINs manualmente cada vez que se necesite esta información.


Procedimiento
¿Qué hace?
Inserta una nueva práctica en la base de datos. El usuario pasa el DNI del estudiante y la matrícula del vehículo,  y el procedimiento busca automáticamente sus IDs internos.
¿Por qué es útil?
Facilita el registro de prácticas sin necesidad de conocer los IDs de la base de datos. Además, valida que el estudiante y el vehículo existan antes de insertar, evitando errores manuales.



Trigers
	1.- 
 ¿Qué hace?
Comprueba que, si se indica un instructor (idempleado_instructor NOT NULL), ese ID pertenezca a alguien que está en la tabla empleados. Si no es así, cancela la inserción lanzando una excepción.

¿Por qué es útil?
La clave foránea de practicas solo verifica que el ID exista en personas, pero no que sea un empleado. Este trigger añade esa validación extra, evitando que se registre como instructor a un estudiante o a alguien externo que no trabaje en la autoescuela.

	2.- 

¿Qué hace?
- En un INSERT: guarda en log_practicas que se añadió una nueva práctica y cuántos minutos tiene.
- En un UPDATE: solo guarda un registro si la duración cambió (compara OLD.duracion_minutos con NEW.duracion_minutos).
 Si solo cambiaron otros campos (p. ej. observaciones), no escribe nada en el log.
¿Por qué es útil?
 Mantiene un historial de cambios en las prácticas. Así se puede saber en cualquier momento cuándo se añadió una clase o cuándo alguien modificó su duración.


Backup

pg_dump -h localhost -U postgres -p 5432 -F p -v -f backup_hermemehildo.sql Hermemehildo

Explicación de los parámetros:
    • -h localhost -U postgres: Define el host y el superusuario para asegurar permisos sobre funciones y triggers.
    • -F p: Formato "plain text" (.sql). Es ideal para ver el código SQL de los procedimientos y triggers.
    • -v: Modo "verbose", para supervisar el progreso de la exportación de tablas y funciones.
    • -f backup_hermemehildo.sql: Nombre del archivo de salida.
    • Hermemehildo: nombre de la base de datos en pg_admin