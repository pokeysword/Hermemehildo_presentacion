
La autoescuela mantiene un registro único de personas que recoge los datos de identificación y contacto (nombre, apellidos, DNI, fecha de nacimiento, dirección y teléfono). A partir de ese registro se gestionan dos perfiles principales:

Empleados, que representan al personal de la autoescuela y se vinculan 1:1 con una persona. Entre empleados puede existir una relación jerárquica mediante un responsable (jefe). Además, un empleado puede disponer de varios teléfonos de empresa.
Estudiantes, que representan al alumnado matriculado y se vinculan 1:1 con una persona.
Vehículos de prácticas
La autoescuela dispone de varios vehículos, cada uno identificado por su matrícula y con información opcional (marca, modelo y color). Cada estudiante tiene asignado un único vehículo para la realización de las clases prácticas.

Asignación de responsables
Cada estudiante queda vinculado a un empleado responsable (por ejemplo, profesor de referencia o tutor), que se utiliza como referencia organizativa dentro de la autoescuela.

Prácticas (clases prácticas)
Para poder conocer cuántas prácticas realiza cada estudiante, se registra cada sesión de práctica indicando:

el estudiante,
la fecha,
la duración real (en minutos), y opcionalmente:
el instructor (empleado) que impartió la práctica,
el vehículo utilizado,
observaciones.
Pruebas y exámenes
La autoescuela gestiona distintos tipos de evaluaciones:

Tests internos: se definen por un número de preguntas, un tiempo máximo y un tema (con dispositivo opcional).
Exámenes teóricos: se definen por una ubicación, un número de preguntas, un tiempo máximo y una categoría de permiso.
Exámenes prácticos: se definen por una ubicación, una duración aproximada y una categoría de permiso.
Los exámenes teóricos y prácticos se clasifican por la categoría del permiso (A, B, C, D, E o T).

Criterio de tiempos
Todas las duraciones y tiempos máximos se registran como valores numéricos en minutos, para evitar ambigüedades y facilitar validaciones y cálculos (por ejemplo, sumas y medias).

Resultados
Cada vez que un estudiante realiza una prueba, se registra un resultado asociado al estudiante y a la prueba correspondiente. En cada resultado se almacena:

la fecha,
la duración real (en minutos),
y el indicador de superación cuando aplica.
En concreto:

En tests, se registra si la prueba fue superada y el número de fallos.
En examen teórico, se registra la fecha y el número de aciertos del estudiante (además de la duración real).
En examen práctico, se registra si fue superado, la duración real y el número de faltas.
Examinador externo
En el examen práctico se identifica:

el profesor, que siempre es un empleado (acompañante o responsable de la preparación), y
el examinador, que se registra como persona y puede ser externo a la autoescuela (no se presupone que sea empleado).
Integridad y restricciones
El modelo aplica reglas de integridad para garantizar coherencia, por ejemplo:

DNI único por persona.
Valores positivos en cantidades de preguntas y duraciones.
En examen práctico, el examinador y el profesor no pueden ser la misma persona.
Las prácticas y resultados quedan vinculados a estudiantes existentes, y las relaciones con empleados/vehículos se controlan mediante referencias y reglas de borrado coherentes.
