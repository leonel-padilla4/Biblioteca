
# Creación de la Base de Datos y Tablas

Lo primero es crear la base de datos con `CREATE DATABASE biblioteca` y 
luego seleccionarla con `USE biblioteca`. Esto le dice a MySQL en qué base
de datos vamos a trabajar.

**Tabla `genero`** — Guarda los géneros literarios. Tiene un `id` autoincrementable como clave primaria y un campo `nombre` para el nombre del género.

**Tabla `autor`** — Almacena los autores. Tiene `id`, `nombre`, `cumpleaños` (tipo DATETIME) y `nacionalidad`.

**Tabla `libro`** — Guarda los libros. Tiene `id`, `titulo`, `isbn`, y dos claves foráneas: `autor_id` que apunta a la tabla `autor`, y `genero_id` que apunta a `genero`. Esto establece la relación entre las tablas.

**Tabla `patron`** — Representa a los usuarios de la biblioteca. Tiene `id`, `nombre`, `email` y `telefono`.

**Tabla `reservas`** — Es la tabla central de operaciones. Relaciona libros con patrones a través de `libro_id` y `patron_id` como claves foráneas, y también guarda la `fecha` de la reserva y el `email` del usuario.

---

## Inserción de Datos

Se insertan 4 géneros: Ficción, Terror, Historia y Ciencia. Luego 4 autores con sus fechas de nacimiento y nacionalidades. Se insertan 8 libros, cada uno vinculado a un autor y un género mediante sus IDs. Se agregan 4 patrones con sus datos de contacto. Finalmente, se insertan 6 reservas que vinculan libros con patrones en fechas específicas.

---

## Consultas

**Consulta 1 — Todos los libros con su autor y género.** Se usa `JOIN` doble para unir `libro` con `autor` y con `genero`, mostrando el título, el nombre del autor y el nombre del género en una sola fila.

**Consulta 2 — Libros que nunca han sido reservados.** Se usa `LEFT JOIN` entre `libro` y `reservas`, y luego se filtra con `WHERE reservas.id IS NULL`. El LEFT JOIN conserva todos los libros aunque no tengan reservas, y el filtro selecciona solo los que no tienen ninguna.

**Consulta 3 — Usuarios que han hecho al menos una reserva.** Se hace un `JOIN` entre `patron` y `reservas`. El `DISTINCT` evita que aparezca el mismo usuario varias veces si tiene más de una reserva.

**Consulta 4 — Cantidad de libros por género.** Se usa `LEFT JOIN` de `genero` hacia `libro` para incluir géneros sin libros, y se agrupa por género con `GROUP BY`. El `COUNT` cuenta cuántos libros tiene cada género.

**Consulta 5 — Total de reservas por libro.** Similar a la anterior pero contando reservas. El `LEFT JOIN` garantiza que aparezcan también los libros con cero reservas.

**Consulta 6 — Autores con más de 3 libros.** Se agrupa por autor y se usa `HAVING COUNT(libro.id) > 3` para filtrar solo los autores con más de 3 libros. Con los datos actuales ningún autor cumple esa condición porque cada uno tiene exactamente 2.

**Consulta 7 — Libros reservados en una fecha específica.** Filtra las reservas usando `WHERE DATE(reservas.fecha) = '2024-01-15'`. La función `DATE()` extrae solo la parte de la fecha, ignorando la hora.

**Consulta 8 — Usuarios que han reservado más de 5 libros.** Agrupa reservas por usuario y filtra con `HAVING COUNT > 5`. Con los datos actuales ningún usuario alcanza ese número.

**Consulta 9 — Libros con su número de reservas incluyendo los de cero.** Es prácticamente igual a la consulta 5. La diferencia semántica es que aquí el objetivo explícito es mostrar todos los libros, incluso los no reservados, usando `LEFT JOIN`.

**Consulta 10 — Género con más libros.** Cuenta libros por género, ordena de mayor a menor con `ORDER BY total_libros DESC` y toma solo el primero con `LIMIT 1`.

**Consulta 11 — El libro más reservado.** Cuenta reservas por libro, ordena descendentemente y toma el primero con `LIMIT 1`. En este caso "Cien años de soledad" y "Sapiens" empatan con 2 reservas cada uno.

**Consulta 12 — Los 3 autores con más reservas acumuladas.** Se hace un doble `LEFT JOIN`: de `autor` a `libro`, y de `libro` a `reservas`. Así se suman todas las reservas de todos los libros de cada autor, y se toman los 3 primeros.

**Consulta 13 — Usuarios que nunca han hecho una reserva.** Usa `LEFT JOIN` de `patron` hacia `reservas` y filtra con `WHERE reservas.id IS NULL`, es el mismo patrón que la consulta 2 pero aplicado a usuarios.

**Consulta 14 — Libros con reservas mayores al promedio.** Usa una subconsulta anidada: primero cuenta las reservas de cada libro, luego calcula el promedio de esos conteos, y finalmente el `HAVING` filtra los libros que superen ese promedio. Es la consulta más compleja del archivo.

**Consulta 15 — Autores cuyos libros pertenecen a más de un género.** Agrupa por autor y cuenta géneros distintos con `COUNT(DISTINCT libro.genero_id)`. El `HAVING > 1` filtra los autores que tienen libros en más de un género. Carl Sagan cumple esto porque tiene libros en Ciencia y en Ficción.
