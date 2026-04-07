
CREATE DATABASE biblioteca;
USE biblioteca;

CREATE TABLE genero (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100)
);

CREATE TABLE autor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    cumpleaños DATETIME,
    nacionalidad VARCHAR(100)
);

CREATE TABLE libro (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(255),
    isbn VARCHAR(255),
    autor_id INT,
    genero_id INT,
    FOREIGN KEY (autor_id) REFERENCES autor(id),
    FOREIGN KEY (genero_id) REFERENCES genero(id)
);

CREATE TABLE patron (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    email VARCHAR(255),
    telefono VARCHAR(100)
);
=======
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    libro_id INT,
    patron_id INT,
    fecha DATETIME,
    email VARCHAR(255),
    FOREIGN KEY (libro_id) REFERENCES libro(id),
    FOREIGN KEY (patron_id) REFERENCES patron(id)
);


INSERT INTO genero (nombre) VALUES
('Ficción'),
('Terror'),
('Historia'),
('Ciencia');

INSERT INTO autor (nombre, cumpleaños, nacionalidad) VALUES
('Gabriel García Márquez', '1927-03-06', 'Colombiana'),
('Stephen King', '1947-09-21', 'Estadounidense'),
('Yuval Noah Harari', '1976-02-24', 'Israelí'),
('Carl Sagan', '1934-11-09', 'Estadounidense');

INSERT INTO libro (titulo, isbn, autor_id, genero_id) VALUES
('Cien años de soledad',  '978-0-06-088328-7', 1, 1),
('El amor en los tiempos del cólera', '978-0-14-028588-4', 1, 1),
('It', '978-0-450-41177-4', 2, 2),
('El resplandor', '978-0-385-12167-5', 2, 2),
('Sapiens', '978-0-06-231609-7', 3, 3),
('Homo Deus', '978-0-06-246431-6', 3, 3),
('Cosmos', '978-0-345-33135-9', 4, 4),
('Contacto', '978-0-671-43400-1', 4, 1);

INSERT INTO patron (nombre, email, telefono) VALUES
('Ana Torres', 'ana@correo.com', '987654321'),
('Luis Medina', 'luis@correo.com', '912345678'),
('María Rojas', 'maria@correo.com', '956781234'),
('Carlos Pérez', 'carlos@correo.com', '945678123');

INSERT INTO reservas (libro_id, patron_id, fecha, email) VALUES
(1, 1, '2024-01-15 10:00:00', 'ana@correo.com'),
(1, 2, '2024-01-15 11:00:00', 'luis@correo.com'),
(3, 1, '2024-02-10 09:00:00', 'ana@correo.com'),
(5, 3, '2024-02-20 14:00:00', 'maria@correo.com'),
(5, 1, '2024-03-01 08:00:00', 'ana@correo.com'),
(7, 2, '2024-03-05 16:00:00', 'luis@correo.com');

-- 1. Todos los libros con su autor y género
SELECT libro.titulo, autor.nombre AS autor, genero.nombre AS genero
FROM libro
JOIN autor ON libro.autor_id = autor.id
JOIN genero ON libro.genero_id = genero.id;

-- 2. Libros que NUNCA han sido reservados
SELECT libro.titulo
FROM libro
LEFT JOIN reservas ON libro.id = reservas.libro_id
WHERE reservas.id IS NULL;

-- 3. Usuarios que han hecho AL MENOS una reserva
SELECT DISTINCT patron.nombre
FROM patron
JOIN reservas ON patron.id = reservas.patron_id;

-- 4. Cantidad de libros por género
SELECT genero.nombre AS genero, COUNT(libro.id) AS total_libros
FROM genero
LEFT JOIN libro ON genero.id = libro.genero_id
GROUP BY genero.id, genero.nombre;

-- 5. Número total de reservas por libro
SELECT libro.titulo, COUNT(reservas.id) AS total_reservas
FROM libro
LEFT JOIN reservas ON libro.id = reservas.libro_id
GROUP BY libro.id, libro.titulo;

-- 6. Autores con más de 3 libros registrados
SELECT autor.nombre, COUNT(libro.id) AS total_libros
FROM autor
JOIN libro ON autor.id = libro.autor_id
GROUP BY autor.id, autor.nombre
HAVING COUNT(libro.id) > 3;

-- 7. Libros reservados en una fecha específica
SELECT libro.titulo, reservas.fecha
FROM reservas
JOIN libro ON reservas.libro_id = libro.id
WHERE DATE(reservas.fecha) = '2024-01-15';

-- 8. Usuarios que han reservado más de 5 libros
SELECT patron.nombre, COUNT(reservas.id) AS total_reservas
FROM patron
JOIN reservas ON patron.id = reservas.patron_id
GROUP BY patron.id, patron.nombre
HAVING COUNT(reservas.id) > 5;

-- 9. Libros con número de veces reservados (incluye los de 0)
SELECT libro.titulo, COUNT(reservas.id) AS veces_reservado
FROM libro
LEFT JOIN reservas ON libro.id = reservas.libro_id
GROUP BY libro.id, libro.titulo;

-- 10. Género con más libros registrados
SELECT genero.nombre, COUNT(libro.id) AS total_libros
FROM genero
LEFT JOIN libro ON genero.id = libro.genero_id
GROUP BY genero.id, genero.nombre
ORDER BY total_libros DESC
LIMIT 1;

-- 11. El libro más reservado
SELECT libro.titulo, COUNT(reservas.id) AS total_reservas
FROM libro
LEFT JOIN reservas ON libro.id = reservas.libro_id
GROUP BY libro.id, libro.titulo
ORDER BY total_reservas DESC
LIMIT 1;

-- 12. Los 3 autores con más reservas acumuladas en sus libros
SELECT autor.nombre, COUNT(reservas.id) AS total_reservas
FROM autor
LEFT JOIN libro ON autor.id = libro.autor_id
LEFT JOIN reservas ON libro.id = reservas.libro_id
GROUP BY autor.id, autor.nombre
ORDER BY total_reservas DESC
LIMIT 3;

-- 13. Usuarios que NUNCA han hecho una reserva
SELECT patron.nombre
FROM patron
LEFT JOIN reservas ON patron.id = reservas.patron_id
WHERE reservas.id IS NULL;

-- 14. Libros cuyas reservas son mayores al promedio
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

-- 15. Autores cuyos libros pertenecen a más de un género distinto
SELECT autor.nombre, COUNT(DISTINCT libro.genero_id) AS generos_distintos
FROM autor
JOIN libro ON autor.id = libro.autor_id
GROUP BY autor.id, autor.nombre
HAVING COUNT(DISTINCT libro.genero_id) > 1;