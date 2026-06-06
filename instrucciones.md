Funciones y procedimientos

Pensad, codificad y explicad 2 funciones (10+10) y un procedimiento (10) útiles para vuestra base de datos en lenguaje PL/pgSQL. 

Para cada función/procedimiento en nuestra memoria incluiremos:

Explicación previa: ¿Qué hace nuestra función/procedimiento? ¿Por qué creemos que es útil?
Código de creación de la función/procedimiento con comentarios
Explicaciones de 3 ejemplos de llamadas con capturas justificativas de sus resultados.
Demostrad el uso de parámetros, variables locales, condicionales, bucles, gestión de excepciones (NO_DATA_FOUND, TOO_MANY_ROWS, OTHERS), consultas con RETURN QUERY / SELECT... INTO, sentencias DML y cursores con múltiples JOINs.

Triggers

Pensad, codificad y explicad 2 disparadores (25+25) útiles para vuestra BD. 

Para cada disparador en nuestra memoria incluiremos:

Explicación previa: ¿Qué desencadena el lanzamiento del trigger? ¿Qué hace el trigger cuando se ejecuta? ¿Por qué se nos ha ocurrido que este trigger puede resultar útil en nuestra BD?
Código de creación del trigger y su función asociada con comentarios
Explicaciones de 3 ejemplos de lanzamiento con capturas justificativas de sus resultados.
¿Cómo se podrían desactivar si no queremos que se lancen?
Demostrad el uso de BEFORE/AFTER, FOR EACH STATEMENT/FOR EACH ROW, NEW/OLD, diferentes RETURN y condicionales.  

Backup

Explicad cómo realizaríais un backup completo de vuestra BD con el comando pg_dump que incluya las tablas y vistas con sus datos y los procedimientos/funciones/triggers que hemos creado para esta entrega. Ojo! Comprobad que dicho fichero permite la restauración íntegra sin errores de vuestra BD .