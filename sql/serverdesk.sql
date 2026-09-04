CREATE DATABASE IF NOT EXISTS serverdesk
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE serverdesk;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS historial;
DROP TABLE IF EXISTS prestamos;
DROP TABLE IF EXISTS equipos;
DROP TABLE IF EXISTS profesores;
DROP TABLE IF EXISTS modelos; 

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE modelos (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    clave VARCHAR(50) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    hostname VARCHAR(100) DEFAULT '-',
    ram VARCHAR(50) DEFAULT '-',
    cpu VARCHAR(150) DEFAULT '-',
    almacenamiento VARCHAR(100) DEFAULT '-',
    gpu VARCHAR(150) DEFAULT '-',
    so VARCHAR(150) DEFAULT '-',

    PRIMARY KEY (id),
    UNIQUE KEY uk_modelos_clave (clave)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


CREATE TABLE profesores (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uk_profesores_nombre (nombre)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE equipos (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,

    codigo VARCHAR(50) NOT NULL,
    numero VARCHAR(50) NOT NULL,

    modelo_id INT UNSIGNED NOT NULL,

    estado ENUM(
        'disponible',
        'prestado',
        'reparacion'
    ) NOT NULL DEFAULT 'disponible',

    reserva VARCHAR(150) DEFAULT '',
    falla VARCHAR(255) DEFAULT '',
    notas TEXT,

    creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    UNIQUE KEY uk_equipos_codigo (codigo),
    UNIQUE KEY uk_equipos_numero (numero),

    KEY idx_equipos_estado (estado),
    KEY idx_equipos_modelo (modelo_id),

    CONSTRAINT fk_equipos_modelo
        FOREIGN KEY (modelo_id)
        REFERENCES modelos(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


CREATE TABLE prestamos (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    equipo_id INT UNSIGNED NOT NULL,
    profesor_id INT UNSIGNED NOT NULL,

    curso VARCHAR(150) DEFAULT '',
    salida DATETIME NOT NULL,

    traspaso_de VARCHAR(150) DEFAULT NULL,

    activo TINYINT(1) NOT NULL DEFAULT 1,

    devolucion DATETIME DEFAULT NULL,

    creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    KEY idx_prestamos_equipo (equipo_id),
    KEY idx_prestamos_profesor (profesor_id),
    KEY idx_prestamos_activo (activo),
    KEY idx_prestamos_salida (salida),

    CONSTRAINT fk_prestamos_equipo
        FOREIGN KEY (equipo_id)
        REFERENCES equipos(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_prestamos_profesor
        FOREIGN KEY (profesor_id)
        REFERENCES profesores(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;



CREATE TABLE historial (
    id VARCHAR(20) NOT NULL,

    tipo ENUM(
        'entrega',
        'devolucion',
        'traspaso',
        'reparacion',
        'alta'
    ) NOT NULL,

    equipo_id INT UNSIGNED DEFAULT NULL,
    codigo VARCHAR(50) NOT NULL,

    profesor_id INT UNSIGNED DEFAULT NULL,
    profesor VARCHAR(150) DEFAULT '',

    curso VARCHAR(150) DEFAULT '',

    fecha DATETIME NOT NULL,

    detalle TEXT,

    PRIMARY KEY (id),

    KEY idx_historial_tipo (tipo),
    KEY idx_historial_codigo (codigo),
    KEY idx_historial_fecha (fecha),
    KEY idx_historial_profesor (profesor_id),

    CONSTRAINT fk_historial_equipo
        FOREIGN KEY (equipo_id)
        REFERENCES equipos(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_historial_profesor
        FOREIGN KEY (profesor_id)
        REFERENCES profesores(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO modelos 
    (clave, nombre, hostname, ram, cpu, almacenamiento, gpu, so)
VALUES
(
    'ci',
    'Conectar Igualdad (blanca)',
    'DESKTOP-CU2CPFP',
    '8,00 GB',
    'Intel Celeron N4020 @ 1.10 GHz',
    '447 GB',
    'Intel UHD Graphics 600',
    'Windows 10 Pro 22H2'
),
(
    'exo',
    'EXO Smart NC74',
    'DESKTOP-FTQSAO3',
    '8,00 GB',
    'Intel Core i7-5500U @ 2.40 GHz (2401 MHz)',
    '1 TB HDD',
    'Intel HD Graphics 5500',
    'Windows 10 Pro · 64 bits (x64)'
),
(
    'noblex',
    'Noblex ECS SF20BA',
    'ECS SF20BA',
    '4,00 GB',
    'Intel Celeron N3060 @ 1.60 GHz (1601 MHz)',
    '128 GB',
    'Intel HD Graphics',
    'Windows 10 Pro · 64 bits (x64)'
),
(
    'dell',
    'Dell',
    'DESKTOP-EDKUGUB',
    '4,00 GB',
    'Intel Celeron N5100 @ 1.10 GHz (1114 MHz)',
    '118 GB',
    'Intel UHD Graphics',
    'Windows 11 Pro · 64 bits (x64)'
),
(
    'cpu',
    'CPU de escritorio',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-'
);



INSERT INTO equipos
    (codigo, numero, modelo_id, estado, reserva, falla, notas)
SELECT
    CONCAT('NET-CI-', LPAD(n, 2, '0')),
    CONCAT('NET-CI-', LPAD(n, 2, '0')),
    id,
    'disponible',
    '',
    '',
    ''
FROM modelos
CROSS JOIN (
    SELECT 1 n
    UNION SELECT 2
    UNION SELECT 3
    UNION SELECT 4
    UNION SELECT 5
    UNION SELECT 6
    UNION SELECT 7
    UNION SELECT 8
    UNION SELECT 9
    UNION SELECT 10
) numeros
WHERE clave = 'ci';


INSERT INTO equipos
    (codigo, numero, modelo_id, estado, reserva, falla, notas)
SELECT
    CONCAT('NET-EXO-', LPAD(n, 2, '0')),
    CONCAT('NET-EXO-', LPAD(n, 2, '0')),
    id,
    'disponible',
    '',
    '',
    ''
FROM modelos
CROSS JOIN (
    SELECT 1 n
    UNION SELECT 2
    UNION SELECT 3
    UNION SELECT 4
    UNION SELECT 5
    UNION SELECT 6
    UNION SELECT 7
    UNION SELECT 8
) numeros
WHERE clave = 'exo';


INSERT INTO equipos
    (codigo, numero, modelo_id, estado, reserva, falla, notas)
SELECT
    CONCAT('NET-NOB-', LPAD(n, 2, '0')),
    CONCAT('NET-NOB-', LPAD(n, 2, '0')),
    id,
    'disponible',
    '',
    '',
    ''
FROM modelos
CROSS JOIN (
    SELECT 1 n
    UNION SELECT 2
    UNION SELECT 3
    UNION SELECT 4
    UNION SELECT 5
    UNION SELECT 6
    UNION SELECT 7
    UNION SELECT 8
) numeros
WHERE clave = 'noblex';


INSERT INTO equipos
    (codigo, numero, modelo_id, estado, reserva, falla, notas)
SELECT
    CONCAT('NET-DELL-', LPAD(n, 2, '0')),
    CONCAT('NET-DELL-', LPAD(n, 2, '0')),
    id,
    'disponible',
    '',
    '',
    ''
FROM modelos
CROSS JOIN (
    SELECT 1 n
    UNION SELECT 2
    UNION SELECT 3
    UNION SELECT 4
    UNION SELECT 5
    UNION SELECT 6
) numeros
WHERE clave = 'dell';

INSERT INTO equipos
    (codigo, numero, modelo_id, estado, reserva, falla, notas)
SELECT
    CONCAT('CPU-4TO-', LPAD(n, 2, '0')),
    CONCAT('CPU-4TO-', LPAD(n, 2, '0')),
    id,
    'disponible',
    '4tos años',
    '',
    ''
FROM modelos
CROSS JOIN (
    SELECT 1 n
    UNION SELECT 2
    UNION SELECT 3
    UNION SELECT 4
) numeros
WHERE clave = 'cpu';


INSERT INTO equipos
    (codigo, numero, modelo_id, estado, reserva, falla, notas)
SELECT
    CONCAT('CPU-LAB-', LPAD(n, 2, '0')),
    CONCAT('CPU-LAB-', LPAD(n, 2, '0')),
    id,
    'disponible',
    'Lab. Sistemas Operativos',
    '',
    ''
FROM modelos
CROSS JOIN (
    SELECT 1 n
    UNION SELECT 2
) numeros
WHERE clave = 'cpu';



CREATE OR REPLACE VIEW vista_equipos AS
SELECT
    e.id,
    e.codigo,
    e.numero,
    e.estado,
    e.reserva,
    e.falla,
    e.notas,

    m.clave AS modelo,
    m.nombre AS modelo_nombre,
    m.hostname,
    m.ram,
    m.cpu,
    m.almacenamiento,
    m.gpu,
    m.so,

    e.creado_en,
    e.actualizado_en

FROM equipos e
INNER JOIN modelos m
    ON m.id = e.modelo_id;

CREATE OR REPLACE VIEW vista_prestamos_actuales AS
SELECT
    p.id AS prestamo_id,

    e.id AS equipo_id,
    e.codigo,
    e.numero,

    m.clave AS modelo,
    m.nombre AS modelo_nombre,

    pr.id AS profesor_id,
    pr.nombre AS profesor,

    p.curso,
    p.salida,
    p.traspaso_de,

    DATE_ADD(p.salida, INTERVAL 120 MINUTE) AS fin_modulo

FROM prestamos p

INNER JOIN equipos e
    ON e.id = p.equipo_id

INNER JOIN modelos m
    ON m.id = e.modelo_id

INNER JOIN profesores pr
    ON pr.id = p.profesor_id

WHERE p.activo = 1;


SELECT
    'Modelos' AS tabla,
    COUNT(*) AS cantidad
FROM modelos

UNION ALL

SELECT
    'Equipos',
    COUNT(*)
FROM equipos

UNION ALL

SELECT
    'Profesores',
    COUNT(*)
FROM profesores

UNION ALL

SELECT
    'Préstamos',
    COUNT(*)
FROM prestamos

UNION ALL

SELECT
    'Historial',
    COUNT(*)
FROM historial;
