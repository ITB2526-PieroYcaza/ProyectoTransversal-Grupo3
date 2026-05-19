-- ============================================================
--  InnovateTech — Base de datos
--  MySQL
--  Creación completa de tablas, índices y datos de prueba
-- ============================================================

CREATE DATABASE IF NOT EXISTS innovatetech_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE innovatetech_db;

-- ------------------------------------------------------------
-- 1. DEPARTAMENTOS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS departamentos (
  id_dep    INT          NOT NULL AUTO_INCREMENT,
  nombre    VARCHAR(100) NOT NULL,
  telefono  VARCHAR(20),
  PRIMARY KEY (id_dep),
  UNIQUE KEY uq_dep_nombre (nombre)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. EMPLEADOS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS empleados (
  dni       VARCHAR(10)  NOT NULL,
  nombre    VARCHAR(80)  NOT NULL,
  apellidos VARCHAR(120) NOT NULL,
  direccion VARCHAR(200),
  telefono  VARCHAR(20),
  id_dep    INT          NOT NULL,
  ldap_uid  VARCHAR(60)  NULL COMMENT 'Rellenar cuando OpenLDAP este configurado',
  PRIMARY KEY (dni),
  UNIQUE KEY uq_ldap_uid (ldap_uid),
  CONSTRAINT fk_emp_dep FOREIGN KEY (id_dep) REFERENCES departamentos(id_dep)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. GRUPOS_CALIDAD  (configuracion de streaming por grupo)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS grupos_calidad (
  id_grupo          INT         NOT NULL AUTO_INCREMENT,
  nombre_grupo      VARCHAR(60) NOT NULL,
  calidad           ENUM('alta','media','baja') NOT NULL DEFAULT 'media',
  max_bitrate_video INT         NOT NULL DEFAULT 2000  COMMENT 'kbps',
  max_bitrate_audio INT         NOT NULL DEFAULT 128   COMMENT 'kbps',
  max_min_mes       INT         NOT NULL DEFAULT 600   COMMENT 'minutos mensuales permitidos',
  max_llamadas_dia  INT         NOT NULL DEFAULT 20,
  PRIMARY KEY (id_grupo)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. USUARIOS_SISTEMA  (empleados + clientes externos)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios_sistema (
  id_usuario      INT          NOT NULL AUTO_INCREMENT,
  nombre_completo VARCHAR(200) NOT NULL,
  email           VARCHAR(150) NOT NULL,
  extension       VARCHAR(20),
  estado          ENUM('activo','bloqueado') NOT NULL DEFAULT 'activo',
  tipo            ENUM('trabajador','cliente_externo') NOT NULL DEFAULT 'trabajador',
  id_grupo        INT          NOT NULL DEFAULT 1,
  ldap_uid        VARCHAR(60)  NULL COMMENT 'Rellenar cuando OpenLDAP este configurado',
  bloqueo_fin     DATETIME     NULL COMMENT 'NULL = indefinido si estado=bloqueado',
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_email (email),
  UNIQUE KEY uq_ldap  (ldap_uid),
  CONSTRAINT fk_usr_grupo FOREIGN KEY (id_grupo) REFERENCES grupos_calidad(id_grupo)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. LLAMADAS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS llamadas (
  id_llamada      INT      NOT NULL AUTO_INCREMENT,
  id_originador   INT      NOT NULL,
  id_destinatario INT      NOT NULL,
  inicio          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fin             DATETIME NULL,
  duracion_min    INT      GENERATED ALWAYS AS
                    (TIMESTAMPDIFF(MINUTE, inicio, fin)) STORED,
  id_calidad      INT      NOT NULL,
  puntuacion      TINYINT  NULL CHECK (puntuacion BETWEEN 1 AND 5),
  comentario      TEXT     NULL,
  PRIMARY KEY (id_llamada),
  CONSTRAINT fk_lla_orig FOREIGN KEY (id_originador)   REFERENCES usuarios_sistema(id_usuario),
  CONSTRAINT fk_lla_dest FOREIGN KEY (id_destinatario) REFERENCES usuarios_sistema(id_usuario),
  CONSTRAINT fk_lla_cal  FOREIGN KEY (id_calidad)      REFERENCES grupos_calidad(id_grupo),
  INDEX idx_lla_orig   (id_originador),
  INDEX idx_lla_dest   (id_destinatario),
  INDEX idx_lla_inicio (inicio)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 6. VIDEOS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS videos (
  id_video          INT          NOT NULL AUTO_INCREMENT,
  titulo            VARCHAR(200) NOT NULL,
  descripcion       TEXT,
  categoria         VARCHAR(80),
  duracion_seg      INT          NULL,
  fecha_publicacion DATE         NOT NULL DEFAULT (CURRENT_DATE),
  url_streaming     VARCHAR(500) NOT NULL,
  codec             VARCHAR(20)  NOT NULL DEFAULT 'H.264',
  formato           VARCHAR(10)  NOT NULL DEFAULT 'MP4',
  PRIMARY KEY (id_video),
  FULLTEXT KEY ft_video (titulo, descripcion, categoria)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 7. MEDICIONES_ANCHO_BANDA
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mediciones_ancho_banda (
  id_medicion  INT          NOT NULL AUTO_INCREMENT,
  fecha_hora   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_operario  INT          NOT NULL,
  bajada_mbps  DECIMAL(8,2) NOT NULL,
  subida_mbps  DECIMAL(8,2) NOT NULL,
  latencia_ms  DECIMAL(8,2) NOT NULL,
  resultado    ENUM('aceptable','no_aceptable') NOT NULL,
  notas        TEXT         NULL,
  PRIMARY KEY (id_medicion),
  CONSTRAINT fk_med_op FOREIGN KEY (id_operario) REFERENCES usuarios_sistema(id_usuario),
  INDEX idx_med_fecha (fecha_hora)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 8. AVISOS_AUDITORIA  (log de triggers)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS avisos_auditoria (
  id_aviso       INT          NOT NULL AUTO_INCREMENT,
  usuario_db     VARCHAR(100) NOT NULL DEFAULT (CURRENT_USER()),
  tabla_afectada VARCHAR(80)  NOT NULL,
  operacion      VARCHAR(20)  NOT NULL,
  fecha_hora     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  detalles       TEXT         NULL,
  PRIMARY KEY (id_aviso),
  INDEX idx_av_fecha (fecha_hora)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 9. CONTROL_BACKUPS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control_backups (
  id_backup        INT          NOT NULL AUTO_INCREMENT,
  fecha_hora       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tablas_incluidas TEXT         NOT NULL,
  resultado        ENUM('ok','error') NOT NULL DEFAULT 'ok',
  ruta_fichero     VARCHAR(500) NULL,
  notas            TEXT         NULL,
  PRIMARY KEY (id_backup)
) ENGINE=InnoDB;

-- ============================================================
--  DATOS DE PRUEBA
-- ============================================================

INSERT INTO departamentos (nombre, telefono) VALUES
  ('Ventas',          '93 100 0001'),
  ('Soporte tecnico', '93 100 0002'),
  ('Administracion',  '93 100 0003'),
  ('Logistica',       '93 100 0004');

INSERT INTO grupos_calidad (nombre_grupo, calidad, max_bitrate_video, max_bitrate_audio, max_min_mes, max_llamadas_dia) VALUES
  ('Grupo Alta',  'alta',  4000, 320, 1200, 50),
  ('Grupo Media', 'media', 2000, 128,  600, 20),
  ('Grupo Baja',  'baja',   500,  64,  300, 10);

INSERT INTO empleados (dni, nombre, apellidos, direccion, telefono, id_dep, ldap_uid) VALUES
  ('12345678A', 'Anna',  'Garcia Lopez',   'Calle Mayor 1, Barcelona',     '600 111 001', 1, NULL),
  ('23456789B', 'Marc',  'Puig Serrano',   'Avda. Diagonal 2, Barcelona',  '600 111 002', 2, NULL),
  ('34567890C', 'Laura', 'Martinez Vidal', 'Calle Nueva 3, Barcelona',     '600 111 003', 3, NULL),
  ('45678901D', 'Jorge', 'Ferrer Mas',     'Paseo de Gracia 4, Barcelona', '600 111 004', 4, NULL),
  ('56789012E', 'Marta', 'Soler Pons',     'Calle Gran 5, Barcelona',      '600 111 005', 1, NULL),
  ('67890123F', 'Pedro', 'Roca Sala',      'Rambla 6, Barcelona',          '600 111 006', 2, NULL);

INSERT INTO usuarios_sistema (nombre_completo, email, extension, estado, tipo, id_grupo, ldap_uid) VALUES
  ('Anna Garcia Lopez',   'anna.garcia@innovatetech.com',    '101', 'activo',    'trabajador',      1, NULL),
  ('Marc Puig Serrano',   'marc.puig@innovatetech.com',      '102', 'activo',    'trabajador',      2, NULL),
  ('Laura Martinez Vidal','laura.martinez@innovatetech.com', '103', 'activo',    'trabajador',      2, NULL),
  ('Jorge Ferrer Mas',    'jorge.ferrer@innovatetech.com',   '104', 'activo',    'trabajador',      3, NULL),
  ('Cliente Externo 1',   'cliente1@external.com',           NULL,  'activo',    'cliente_externo', 2, NULL),
  ('Cliente Externo 2',   'cliente2@external.com',           NULL,  'bloqueado', 'cliente_externo', 3, NULL);

INSERT INTO videos (titulo, descripcion, categoria, duracion_seg, url_streaming, codec, formato) VALUES
  ('Formacion onboarding', 'Video de bienvenida para nuevos empleados', 'Formacion', 1200, 'rtmp://stream.innovatetech.com/live/onboarding', 'H.264', 'MP4'),
  ('Manual ERP interno',   'Guia de uso del sistema ERP',               'Tutorial',  3600, 'rtmp://stream.innovatetech.com/live/erp',        'H.264', 'MP4'),
  ('Reunion Q1 2025',      'Resumen de resultados del primer trimestre', 'Reunion',    900, 'rtmp://stream.innovatetech.com/live/q1-2025',    'H.264', 'MP4');

INSERT INTO llamadas (id_originador, id_destinatario, inicio, fin, id_calidad, puntuacion, comentario) VALUES
  (1, 2, '2025-05-01 10:00:00', '2025-05-01 10:25:00', 1, 5, 'Muy buena calidad'),
  (2, 3, '2025-05-02 11:00:00', '2025-05-02 11:10:00', 2, 4, NULL),
  (1, 5, '2025-05-03 09:00:00', '2025-05-03 09:45:00', 2, 3, 'Algunas interrupciones');

INSERT INTO mediciones_ancho_banda (id_operario, bajada_mbps, subida_mbps, latencia_ms, resultado, notas) VALUES
  (1, 95.40, 45.20, 12.5, 'aceptable',    'Prueba manana, red estable'),
  (2, 12.10,  5.80, 85.3, 'no_aceptable', 'Prueba tarde, congestion detectada');