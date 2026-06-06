/*1. Promedio de fallos por test, agrupado por tema y dispositivo. -> Calcula el promedio de fallos por test, agrupado por tema y dispositivo, y filtra aquellos con más de 1 fallo promedio.*/
SELECT t.tema, t.dispositivo, AVG(nt.num_fallos) AS promedio_fallos
FROM tests t
JOIN notas_tests nt ON t.idtest = nt.idtest
GROUP BY t.tema, t.dispositivo
HAVING AVG(nt.num_fallos) > 1;


/*2. Estudiantes con prácticas, test y exámenes prácticos aprobados. ->  Muestra el número de prácticas, tests aprobados y exámenes prácticos aprobados por cada estudiante.*/
SELECT p.nombre, p.apellido1, COUNT(DISTINCT pr.idpractica) AS num_practicas, COUNT(DISTINCT nt.idtest) AS num_tests, COUNT(DISTINCT nep.idexamenP) AS examenes_aprobados
FROM personas p
JOIN estudiantes e ON p.idpersona = e.idpersona
JOIN practicas pr ON e.idpersona = pr.idestudiante
JOIN notas_tests nt ON e.idpersona = nt.idestudiante AND nt.aprobado = TRUE
JOIN notas_examenP nep ON e.idpersona = nep.idestudiante AND nep.aprobado = TRUE
GROUP BY p.idpersona;


/*3. Estudiantes sin prácticas registradas. ->Lista los estudiantes que no tienen ninguna práctica registrada. El left join permite detectar la ausencia de registros en la tabla practicas.*/
SELECT DISTINCT(p.nombre), p.apellido1, pr.idpractica
FROM estudiantes e
JOIN personas p ON e.idpersona = p.idpersona
LEFT JOIN practicas pr ON e.idpersona = pr.idestudiante
WHERE pr.idpractica IS NULL;


 
/*4. Mostrar los estudiantes que han aprobado algún test*/
SELECT p.idpersona,p.nombre,p.apellido1
FROM personas p
JOIN estudiantes e ON p.idpersona = e.idpersona
WHERE p.idpersona IN (
    SELECT nt.idestudiante
    FROM notas_tests nt
    WHERE nt.aprobado = TRUE
);


/*5. Número acumulado de prácticas por estudiante. -> Muestra la duración acumulada de prácticas por estudiante a lo largo del tiempo. Usa SUM OVER como window function para calcular el total progresivo*/
SELECT Distinct(e.idpersona), p.nombre, p.apellido1, pr.fecha, SUM(pr.duracion_minutos) OVER (PARTITION BY e.idpersona ORDER BY pr.fecha) AS duracion_acumulada
FROM practicas pr
JOIN estudiantes e ON pr.idestudiante = e.idpersona
JOIN personas p ON e.idpersona = p.idpersona;


/*6. Relación entre tipo de examen práctico y número de faltas. -> Agrupa los exámenes prácticos por tipo y calcula el promedio de faltas, mostrando solo aquellos tipos con más de 2 faltas promedio.*/
SELECT  ep.tipo ,AVG(nep.num_faltas) AS promedio_faltas
FROM examenesP ep
JOIN notas_examenP nep ON ep.idexamenP = nep.idexamenP
GROUP BY ep.tipo
HAVING AVG(nep.num_faltas) > 2;

