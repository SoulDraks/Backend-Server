CREATE DATABASE IF NOT EXISTS serverdesk
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE serverdesk;

CREATE TABLE IF NOT EXISTS modelos (
  clave VARCHAR(32) NOT NULL PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  hostname VARCHAR(120) NOT NULL DEFAULT '-',
  ram VARCHAR(60) NOT NULL DEFAULT '-',
  cpu VARCHAR(120) NOT NULL DEFAULT '-',
  almacenamiento VARCHAR(60) NOT NULL DEFAULT '-',
  gpu VARCHAR(120) NOT NULL DEFAULT '-',
  so VARCHAR(120) NOT NULL DEFAULT '-'
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE IF NOT EXISTS equipos (
  codigo VARCHAR(64) NOT NULL PRIMARY KEY,
  numero VARCHAR(64) NOT NULL,
  modelo VARCHAR(32) NOT NULL,
  estado ENUM('disponible','prestado','reparacion') NOT NULL DEFAULT 'disponible',
  reserva VARCHAR(120) NOT NULL DEFAULT '',
  falla VARCHAR(120) NOT NULL DEFAULT '',
  notas TEXT NULL,
  prestamo JSON NULL,
  actualizado DATETIME NOT NULL,
  INDEX equipos_estado (estado),
  CONSTRAINT equipos_modelo_fk FOREIGN KEY (modelo) REFERENCES modelos (clave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS movimientos (
  id VARCHAR(32) NOT NULL PRIMARY KEY,
  tipo ENUM('entrega','devolucion','traspaso','reparacion','alta') NOT NULL,
  codigo VARCHAR(64) NOT NULL,
  profesor VARCHAR(120) NOT NULL DEFAULT '',
  curso VARCHAR(60) NOT NULL DEFAULT '',
  detalle VARCHAR(200) NOT NULL DEFAULT '',
  fecha DATETIME NOT NULL,
  INDEX movimientos_fecha (fecha),
  INDEX movimientos_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE VIEW pendientes AS
SELECT
  e.codigo,
  e.numero,
  m.nombre AS modelo,
  JSON_UNQUOTE(JSON_EXTRACT(e.prestamo, '$.profesor')) AS profesor,
  JSON_UNQUOTE(JSON_EXTRACT(e.prestamo, '$.curso')) AS curso,
  STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(e.prestamo, '$.salida')), '%Y-%m-%dT%H:%i:%s.%fZ') AS salida_utc,
  e.reserva
FROM equipos e
JOIN modelos m ON m.clave = e.modelo
WHERE e.estado = 'prestado';

INSERT IGNORE INTO modelos (clave, nombre, hostname, ram, cpu, almacenamiento, gpu, so) VALUES
  ('ci', 'Conectar Igualdad (blanca)', 'DESKTOP-CU2CPFP', '8,00 GB', 'Intel Celeron N4020 @ 1.10 GHz', '447 GB', 'Intel UHD Graphics 600', 'Windows 10 Pro 22H2'),
  ('exo', 'EXO Smart NC74', 'DESKTOP-FTQSAO3', '8,00 GB', 'Intel Core i7-5500U @ 2.40 GHz (2401 MHz)', '1 TB HDD', 'Intel HD Graphics 5500', 'Windows 10 Pro · 64 bits (x64)'),
  ('noblex', 'Noblex ECS SF20BA', 'ECS SF20BA', '4,00 GB', 'Intel Celeron N3060 @ 1.60 GHz (1601 MHz)', '128 GB', 'Intel HD Graphics', 'Windows 10 Pro · 64 bits (x64)'),
  ('dell', 'Dell', 'DESKTOP-EDKUGUB', '4,00 GB', 'Intel Celeron N5100 @ 1.10 GHz (1114 MHz)', '118 GB', 'Intel UHD Graphics', 'Windows 11 Pro · 64 bits (x64)'),
  ('cpu', 'CPU de escritorio', '-', '-', '-', '-', '-', '-');

INSERT IGNORE INTO equipos (codigo, numero, modelo, estado, reserva, falla, notas, prestamo, actualizado) VALUES
  ('NET-CI-01','NET-CI-01','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-CI-02','NET-CI-02','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-CI-03','NET-CI-03','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-CI-04','NET-CI-04','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-CI-05','NET-CI-05','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-CI-06','NET-CI-06','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-CI-07','NET-CI-07','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-CI-08','NET-CI-08','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-CI-09','NET-CI-09','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-CI-10','NET-CI-10','ci','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-EXO-01','NET-EXO-01','exo','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-EXO-02','NET-EXO-02','exo','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-EXO-03','NET-EXO-03','exo','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-EXO-04','NET-EXO-04','exo','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-EXO-05','NET-EXO-05','exo','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-EXO-06','NET-EXO-06','exo','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-EXO-07','NET-EXO-07','exo','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-EXO-08','NET-EXO-08','exo','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-NOB-01','NET-NOB-01','noblex','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-NOB-02','NET-NOB-02','noblex','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-NOB-03','NET-NOB-03','noblex','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-NOB-04','NET-NOB-04','noblex','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-NOB-05','NET-NOB-05','noblex','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-NOB-06','NET-NOB-06','noblex','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-NOB-07','NET-NOB-07','noblex','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-NOB-08','NET-NOB-08','noblex','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-DELL-01','NET-DELL-01','dell','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-DELL-02','NET-DELL-02','dell','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-DELL-03','NET-DELL-03','dell','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-DELL-04','NET-DELL-04','dell','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-DELL-05','NET-DELL-05','dell','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('NET-DELL-06','NET-DELL-06','dell','disponible','','',NULL,NULL,UTC_TIMESTAMP()),
  ('CPU-4TO-01','CPU-4TO-01','cpu','disponible','4tos años','',NULL,NULL,UTC_TIMESTAMP()),
  ('CPU-4TO-02','CPU-4TO-02','cpu','disponible','4tos años','',NULL,NULL,UTC_TIMESTAMP()),
  ('CPU-4TO-03','CPU-4TO-03','cpu','disponible','4tos años','',NULL,NULL,UTC_TIMESTAMP()),
  ('CPU-4TO-04','CPU-4TO-04','cpu','disponible','4tos años','',NULL,NULL,UTC_TIMESTAMP()),
  ('CPU-LAB-01','CPU-LAB-01','cpu','disponible','Lab. Sistemas Operativos','',NULL,NULL,UTC_TIMESTAMP()),
  ('CPU-LAB-02','CPU-LAB-02','cpu','disponible','Lab. Sistemas Operativos','',NULL,NULL,UTC_TIMESTAMP());
