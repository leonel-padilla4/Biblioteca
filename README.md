
## Creación de la Base de Datos y Tablas
```
Lo primero es crear la base de datos con `CREATE DATABASE biblioteca` y 
luego seleccionarla con `USE biblioteca`. Esto le dice a MySQL en qué base
de datos vamos a trabajar.
```
```
**Tabla `genero`** — Guarda los géneros literarios. Tiene un `id` autoincrementable 
como clave primaria y un campo `nombre` para el nombre del género.
```
```
**Tabla `autor`** — Almacena los autores. 
Tiene `id`, `nombre`, `cumpleaños` (tipo DATETIME) y `nacionalidad`.
```
```
**Tabla `libro`** — Guarda los libros. Tiene `id`, `titulo`, `isbn`,
y dos claves foráneas: `autor_id` que apunta a la tabla `autor`, y
`genero_id` que apunta a `genero`. Esto establece la relación entre las tablas.
```
```
**Tabla `patron`** — Representa a los usuarios de la biblioteca.
Tiene `id`, `nombre`, `email` y `telefono`.
```
```
**Tabla `reservas`** — Es la tabla central de operaciones.
Relaciona libros con patrones a través de `libro_id` y
`patron_id` como claves foráneas, y también
guarda la `fecha` de la reserva y el `email` del usuario.
```
## Inserción de Datos
```
Se insertan 4 géneros: Ficción, Terror, Historia y Ciencia.
Luego 4 autores con sus fechas de nacimiento y nacionalidades.
Se insertan 8 libros, cada uno vinculado a un autor y un género mediante sus IDs.
Se agregan 4 patrones con sus datos de contacto. Finalmente,
se insertan 6 reservas que vinculan libros con patrones en fechas específicas.
```

## Consultas
```
**Consulta 1 — Todos los libros con su autor y género.
Se usa `JOIN` doble para unir `libro` con `autor` y con `genero`,
mostrando el título, el nombre del autor y el nombre del género en una sola fila.

SELECT libro.titulo, autor.nombre AS autor, genero.nombre AS genero
FROM libro
JOIN autor ON libro.autor_id = autor.id
JOIN genero ON libro.genero_id = genero.id;
```
```
**Consulta 2 — Libros que nunca han sido reservados.
Se usa `LEFT JOIN` entre `libro` y `reservas`, y luego
se filtra con `WHERE reservas.id IS NULL`. El LEFT JOIN conserva
todos los libros aunque no tengan reservas, y el filtro selecciona solo los que no tienen ninguna.

SELECT libro.titulo
FROM libro
LEFT JOIN reservas ON libro.id = reservas.libro_id
WHERE reservas.id IS NULL;
```
```
**Consulta 3 — Usuarios que han hecho al menos una reserva.
Se hace un `JOIN` entre `patron` y `reservas`. El `DISTINCT`
evita que aparezca el mismo usuario varias veces si tiene más de una reserva.

SELECT DISTINCT patron.nombre
FROM patron
JOIN reservas ON patron.id = reservas.patron_id;
```
```
**Consulta 4 — Cantidad de libros por género.
Se usa `LEFT JOIN` de `genero` hacia `libro` para incluir géneros sin libros,
y se agrupa por género con `GROUP BY`. El `COUNT` cuenta cuántos libros tiene cada género.

SELECT genero.nombre AS genero, COUNT(libro.id) AS total_libros
FROM genero
LEFT JOIN libro ON genero.id = libro.genero_id
GROUP BY genero.id, genero.nombre;
```
```
**Consulta 5 — Total de reservas por libro.
Similar a la anterior pero contando reservas.
El `LEFT JOIN` garantiza que aparezcan también los libros con cero reservas.

SELECT libro.titulo, COUNT(reservas.id) AS total_reservas
FROM libro
LEFT JOIN reservas ON libro.id = reservas.libro_id
GROUP BY libro.id, libro.titulo;
```
```
**Consulta 6 — Autores con más de 3 libros.
Se agrupa por autor y se usa `HAVING COUNT(libro.id) > 3` para filtrar
solo los autores con más de 3 libros. Con los datos actuales ningún autor
cumple esa condición porque cada uno tiene exactamente 2.

SELECT autor.nombre, COUNT(libro.id) AS total_libros
FROM autor
JOIN libro ON autor.id = libro.autor_id
GROUP BY autor.id, autor.nombre
HAVING COUNT(libro.id) > 3;
```
```
**Consulta 7 — Libros reservados en una fecha específica.
Filtra las reservas usando `WHERE DATE(reservas.fecha) = '2024-01-15'`.
La función `DATE()` extrae solo la parte de la fecha, ignorando la hora.

SELECT libro.titulo, reservas.fecha
FROM reservas
JOIN libro ON reservas.libro_id = libro.id
WHERE DATE(reservas.fecha) = '2024-01-15';
```
```
**Consulta 8 — Usuarios que han reservado más de 5 libros.
Agrupa reservas por usuario y filtra con `HAVING COUNT > 5`.
Con los datos actuales ningún usuario alcanza ese número.

SELECT patron.nombre, COUNT(reservas.id) AS total_reservas
FROM patron
JOIN reservas ON patron.id = reservas.patron_id
GROUP BY patron.id, patron.nombre
HAVING COUNT(reservas.id) > 5;
```
```
**Consulta 9 — Libros con su número de reservas incluyendo los de cero.
Es prácticamente igual a la consulta 5. La diferencia semántica es que
aquí el objetivo explícito es mostrar todos los libros, incluso los no reservados, usando `LEFT JOIN`.

SELECT libro.titulo, COUNT(reservas.id) AS veces_reservado
FROM libro
LEFT JOIN reservas ON libro.id = reservas.libro_id
GROUP BY libro.id, libro.titulo;
```
```
**Consulta 10 — Género con más libros. Cuenta libros por género,
ordena de mayor a menor con `ORDER BY total_libros DESC` y
toma solo el primero con `LIMIT 1`.

SELECT genero.nombre, COUNT(libro.id) AS total_libros
FROM genero
LEFT JOIN libro ON genero.id = libro.genero_id
GROUP BY genero.id, genero.nombre
ORDER BY total_libros DESC
LIMIT 1;
```
```
**Consulta 11 — El libro más reservado.
Cuenta reservas por libro, ordena descendentemente y
toma el primero con `LIMIT 1`. En este caso "Cien años de soledad" y
"Sapiens" empatan con 2 reservas cada uno.

SELECT libro.titulo, COUNT(reservas.id) AS total_reservas
FROM libro
LEFT JOIN reservas ON libro.id = reservas.libro_id
GROUP BY libro.id, libro.titulo
ORDER BY total_reservas DESC
LIMIT 1;
```
```
**Consulta 12 — Los 3 autores con más reservas acumuladas.
Se hace un doble `LEFT JOIN`: de `autor` a `libro`, y de `libro` a `reservas`.
Así se suman todas las reservas de todos los libros de cada autor, y se toman los 3 primeros.

SELECT autor.nombre, COUNT(reservas.id) AS total_reservas
FROM autor
LEFT JOIN libro ON autor.id = libro.autor_id
LEFT JOIN reservas ON libro.id = reservas.libro_id
GROUP BY autor.id, autor.nombre
ORDER BY total_reservas DESC
LIMIT 3;
```
```
**Consulta 13 — Usuarios que nunca han hecho una reserva.
Usa `LEFT JOIN` de `patron` hacia `reservas` y filtra con `WHERE reservas.id IS NULL`,
es el mismo patrón que la consulta 2 pero aplicado a usuarios.

SELECT patron.nombre
FROM patron
LEFT JOIN reservas ON patron.id = reservas.patron_id
WHERE reservas.id IS NULL;
```
```
**Consulta 14 — Libros con reservas mayores al promedio.
Usa una subconsulta anidada: primero cuenta las reservas de cada libro,
luego calcula el promedio de esos conteos, y finalmente el `HAVING` filtra
los libros que superen ese promedio. Es la consulta más compleja del archivo.

SELECT libro.titulo, COUNT(reservas.id) AS total_reservas
FROM libro
LEFT JOIN reservas ON libro.id = reservas.libro_id
GROUP BY libro.id, libro.titulo
HAVING COUNT(reservas.id) > (
    SELECT AVG(conteo) FROM (
        SELECT COUNT(id) AS conteo
        FROM reservas
        GROUP BY libro_id
    ) AS sub
);
```
```
**Consulta 15 — Autores cuyos libros pertenecen a más de un género.
Agrupa por autor y cuenta géneros distintos con `COUNT(DISTINCT libro.genero_id)`.
El `HAVING > 1` filtra los autores que tienen libros en más de un género.
Carl Sagan cumple esto porque tiene libros en Ciencia y en Ficción.

SELECT autor.nombre, COUNT(DISTINCT libro.genero_id) AS generos_distintos
FROM autor
JOIN libro ON autor.id = libro.autor_id
GROUP BY autor.id, autor.nombre
HAVING COUNT(DISTINCT libro.genero_id) > 1;
```
