-- ============================================================
--  InnovateTech — Triggers y Eventos
--  MySQL
--  Ejecutar DESPUÉS de schema.sql
-- ============================================================

USE innovatetech_db;

-- Necesario para que funcionen los eventos periódicos
SET GLOBAL event_scheduler = ON;

DELIMITER $$

-- ============================================================
--  BLOQUE 1: CONTROL DE CUOTAS DE LLAMADAS
-- ============================================================

-- ------------------------------------------------------------
-- Trigger 1: Bloquear si se supera el límite de minutos mensuales
-- ------------------------------------------------------------
CREATE TRIGGER trg_control_minutos_mensuales
BEFORE INSERT ON llamadas
FOR EACH ROW
BEGIN
    DECLARE total_minutos INT DEFAULT 0;
    DECLARE limite_minutos INT DEFAULT 0;

    -- Sumar minutos usados este mes por el originador
    SELECT COALESCE(SUM(duracion_min), 0)
      INTO total_minutos
      FROM llamadas
     WHERE id_originador = NEW.id_originador
       AND MONTH(inicio) = MONTH(NOW())
       AND YEAR(inicio)  = YEAR(NOW());

    -- Obtener el límite del grupo del usuario
    SELECT gq.max_min_mes
      INTO limite_minutos
      FROM usuarios_sistema us
      JOIN grupos_calidad gq ON us.id_grupo = gq.id_grupo
     WHERE us.id_usuario = NEW.id_originador;

    -- Si supera el límite, registrar aviso y bloquear inserción
    IF total_minutos >= limite_minutos THEN
        INSERT INTO avisos_auditoria (usuario_db, tabla_afectada, operacion, detalles)
        VALUES (
            CURRENT_USER(),
            'llamadas',
            'INSERT bloqueado',
            CONCAT(
                'Usuario ID ', NEW.id_originador,
                ' ha superado el limite mensual de ', limite_minutos,
                ' minutos. Minutos usados: ', total_minutos
            )
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Limite de minutos mensuales alcanzado. Llamada bloqueada.';
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 2: Bloquear si se supera el máximo de llamadas diarias
-- ------------------------------------------------------------
CREATE TRIGGER trg_control_llamadas_diarias
BEFORE INSERT ON llamadas
FOR EACH ROW
BEGIN
    DECLARE llamadas_hoy INT DEFAULT 0;
    DECLARE limite_diario INT DEFAULT 0;

    -- Contar llamadas de hoy del originador
    SELECT COUNT(*)
      INTO llamadas_hoy
      FROM llamadas
     WHERE id_originador = NEW.id_originador
       AND DATE(inicio) = CURDATE();

    -- Obtener el límite diario del grupo
    SELECT gq.max_llamadas_dia
      INTO limite_diario
      FROM usuarios_sistema us
      JOIN grupos_calidad gq ON us.id_grupo = gq.id_grupo
     WHERE us.id_usuario = NEW.id_originador;

    IF llamadas_hoy >= limite_diario THEN
        INSERT INTO avisos_auditoria (usuario_db, tabla_afectada, operacion, detalles)
        VALUES (
            CURRENT_USER(),
            'llamadas',
            'INSERT bloqueado',
            CONCAT(
                'Usuario ID ', NEW.id_originador,
                ' ha superado el limite diario de ', limite_diario,
                ' llamadas. Llamadas hoy: ', llamadas_hoy
            )
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Limite de llamadas diarias alcanzado. Llamada bloqueada.';
    END IF;
END$$


-- ============================================================
--  BLOQUE 2: BLOQUEO DE USUARIOS
-- ============================================================

-- ------------------------------------------------------------
-- Trigger 3: Impedir llamadas si el originador está bloqueado
-- ------------------------------------------------------------
CREATE TRIGGER trg_bloqueo_originador
BEFORE INSERT ON llamadas
FOR EACH ROW
BEGIN
    DECLARE estado_usuario VARCHAR(20);
    DECLARE fin_bloqueo DATETIME;

    SELECT estado, bloqueo_fin
      INTO estado_usuario, fin_bloqueo
      FROM usuarios_sistema
     WHERE id_usuario = NEW.id_originador;

    -- Si está bloqueado y el bloqueo no ha expirado (o es indefinido)
    IF estado_usuario = 'bloqueado' AND (fin_bloqueo IS NULL OR fin_bloqueo > NOW()) THEN
        INSERT INTO avisos_auditoria (usuario_db, tabla_afectada, operacion, detalles)
        VALUES (
            CURRENT_USER(),
            'llamadas',
            'INSERT bloqueado',
            CONCAT('Usuario ID ', NEW.id_originador, ' esta bloqueado. No puede realizar llamadas.')
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Usuario bloqueado. No puede realizar llamadas.';
    END IF;

    -- Si el bloqueo ya expiró, desbloquear automáticamente
    IF estado_usuario = 'bloqueado' AND fin_bloqueo IS NOT NULL AND fin_bloqueo <= NOW() THEN
        UPDATE usuarios_sistema
           SET estado = 'activo', bloqueo_fin = NULL
         WHERE id_usuario = NEW.id_originador;
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 4: Impedir recibir llamadas si el destinatario está bloqueado
-- ------------------------------------------------------------
CREATE TRIGGER trg_bloqueo_destinatario
BEFORE INSERT ON llamadas
FOR EACH ROW
BEGIN
    DECLARE estado_dest VARCHAR(20);
    DECLARE fin_bloqueo_dest DATETIME;

    SELECT estado, bloqueo_fin
      INTO estado_dest, fin_bloqueo_dest
      FROM usuarios_sistema
     WHERE id_usuario = NEW.id_destinatario;

    IF estado_dest = 'bloqueado' AND (fin_bloqueo_dest IS NULL OR fin_bloqueo_dest > NOW()) THEN
        INSERT INTO avisos_auditoria (usuario_db, tabla_afectada, operacion, detalles)
        VALUES (
            CURRENT_USER(),
            'llamadas',
            'INSERT bloqueado',
            CONCAT('Usuario ID ', NEW.id_destinatario, ' esta bloqueado. No puede recibir llamadas.')
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El destinatario esta bloqueado. No puede recibir llamadas.';
    END IF;
END$$



-- ============================================================
--  BLOQUE 3: AUDITORÍA DE ACCESOS NO AUTORIZADOS
-- ============================================================

-- Nota: En MySQL los triggers no pueden saber el ROL del usuario
-- de base de datos directamente, pero sí el CURRENT_USER().
-- La estrategia es: el script de creación de usuarios (sección 3.3.2)
-- crea usuarios con nombres que incluyen el rol (ej: ventas_anna,
-- administracion_jorge), y los triggers filtran por prefijo de usuario.

-- ------------------------------------------------------------
-- Trigger 5: Auditar intento de modificar empleados/nóminas
-- por usuarios con rol trabajador o ventas
-- ------------------------------------------------------------
CREATE TRIGGER trg_auditoria_empleados_update
BEFORE UPDATE ON empleados
FOR EACH ROW
BEGIN
    DECLARE usuario_actual VARCHAR(100);
    SET usuario_actual = CURRENT_USER();

    -- Bloquear si el usuario tiene prefijo 'trabajador_' o 'ventas_'
    IF usuario_actual LIKE 'trabajador_%' OR usuario_actual LIKE 'ventas_%' THEN
        INSERT INTO avisos_auditoria (usuario_db, tabla_afectada, operacion, detalles)
        VALUES (
            usuario_actual,
            'empleados',
            'UPDATE no autorizado',
            CONCAT('Intento de modificar empleado DNI: ', OLD.dni)
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Acceso denegado: no tiene permisos para modificar empleados.';
    END IF;
END$$

CREATE TRIGGER trg_auditoria_empleados_delete
BEFORE DELETE ON empleados
FOR EACH ROW
BEGIN
    DECLARE usuario_actual VARCHAR(100);
    SET usuario_actual = CURRENT_USER();

    IF usuario_actual LIKE 'trabajador_%' OR usuario_actual LIKE 'ventas_%' THEN
        INSERT INTO avisos_auditoria (usuario_db, tabla_afectada, operacion, detalles)
        VALUES (
            usuario_actual,
            'empleados',
            'DELETE no autorizado',
            CONCAT('Intento de eliminar empleado DNI: ', OLD.dni)
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Acceso denegado: no tiene permisos para eliminar empleados.';
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 6: Auditar intento de modificar grupos_calidad
-- (configuración de roles/calidad) por trabajador o ventas
-- ------------------------------------------------------------
CREATE TRIGGER trg_auditoria_grupos_calidad_update
BEFORE UPDATE ON grupos_calidad
FOR EACH ROW
BEGIN
    DECLARE usuario_actual VARCHAR(100);
    SET usuario_actual = CURRENT_USER();

    IF usuario_actual LIKE 'trabajador_%' OR usuario_actual LIKE 'ventas_%' THEN
        INSERT INTO avisos_auditoria (usuario_db, tabla_afectada, operacion, detalles)
        VALUES (
            usuario_actual,
            'grupos_calidad',
            'UPDATE no autorizado',
            CONCAT('Intento de modificar grupo ID: ', OLD.id_grupo, ' (', OLD.nombre_grupo, ')')
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Acceso denegado: no tiene permisos para modificar la configuracion de roles.';
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 7: Auditar intento de acceso a llamadas
-- por usuarios con rol administracion
-- ------------------------------------------------------------
CREATE TRIGGER trg_auditoria_llamadas_admin_insert
BEFORE INSERT ON llamadas
FOR EACH ROW
BEGIN
    DECLARE usuario_actual VARCHAR(100);
    SET usuario_actual = CURRENT_USER();

    IF usuario_actual LIKE 'administracion_%' THEN
        INSERT INTO avisos_auditoria (usuario_db, tabla_afectada, operacion, detalles)
        VALUES (
            usuario_actual,
            'llamadas',
            'INSERT no autorizado',
            CONCAT(
                'Administracion intento insertar llamada: originador ID ',
                NEW.id_originador, ' -> destinatario ID ', NEW.id_destinatario
            )
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Acceso denegado: administracion no puede gestionar llamadas de clientes.';
    END IF;
END$$

CREATE TRIGGER trg_auditoria_llamadas_admin_update
BEFORE UPDATE ON llamadas
FOR EACH ROW
BEGIN
    DECLARE usuario_actual VARCHAR(100);
    SET usuario_actual = CURRENT_USER();

    IF usuario_actual LIKE 'administracion_%' THEN
        INSERT INTO avisos_auditoria (usuario_db, tabla_afectada, operacion, detalles)
        VALUES (
            usuario_actual,
            'llamadas',
            'UPDATE no autorizado',
            CONCAT('Administracion intento modificar llamada ID: ', OLD.id_llamada)
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Acceso denegado: administracion no puede modificar llamadas de clientes.';
    END IF;
END$$


-- ============================================================
--  BLOQUE 4: EVENTO PERIÓDICO DE BACKUP
-- ============================================================

-- Backup diario a las 02:00 AM
-- Justificación: se elige periodicidad diaria porque los datos de
-- llamadas, empleados y mediciones cambian cada día. Un backup
-- semanal supondría perder hasta 7 días de actividad en caso de fallo.
-- La hora 02:00 AM minimiza el impacto en rendimiento del servidor.

CREATE EVENT evt_backup_diario
ON SCHEDULE EVERY 1 DAY
STARTS (DATE(NOW()) + INTERVAL 1 DAY + INTERVAL 2 HOUR)
DO
BEGIN
    DECLARE ruta_base VARCHAR(200);
    DECLARE fecha_str VARCHAR(20);
    DECLARE resultado_backup ENUM('ok','error') DEFAULT 'ok';
    DECLARE msg_error TEXT DEFAULT NULL;

    SET fecha_str = DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s');
    SET ruta_base = '/var/backups/innovatetech';

    -- Backup tabla empleados
    SET @sql = CONCAT(
        "SELECT * INTO OUTFILE '", ruta_base, "/empleados_", fecha_str, ".csv' ",
        "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ",
        "LINES TERMINATED BY '\n' ",
        "FROM empleados"
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Backup tabla usuarios_sistema (clientes)
    SET @sql = CONCAT(
        "SELECT * INTO OUTFILE '", ruta_base, "/usuarios_sistema_", fecha_str, ".csv' ",
        "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ",
        "LINES TERMINATED BY '\n' ",
        "FROM usuarios_sistema"
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Backup tabla llamadas (registro de actividad)
    SET @sql = CONCAT(
        "SELECT * INTO OUTFILE '", ruta_base, "/llamadas_", fecha_str, ".csv' ",
        "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ",
        "LINES TERMINATED BY '\n' ",
        "FROM llamadas"
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Backup tabla videos
    SET @sql = CONCAT(
        "SELECT * INTO OUTFILE '", ruta_base, "/videos_", fecha_str, ".csv' ",
        "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ",
        "LINES TERMINATED BY '\n' ",
        "FROM videos"
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Registrar el evento en la tabla de control
    INSERT INTO control_backups (tablas_incluidas, resultado, ruta_fichero, notas)
    VALUES (
        'empleados, usuarios_sistema, llamadas, videos',
        resultado_backup,
        CONCAT(ruta_base, '/*_', fecha_str, '.csv'),
        CONCAT('Backup automatico diario ejecutado a las ', NOW())
    );

END$$

DELIMITER ;

-- ============================================================
--  Crear directorio de backups (ejecutar en bash, no en MySQL)
--  sudo mkdir -p /var/backups/innovatetech
--  sudo chown mysql:mysql /var/backups/innovatetech
-- ============================================================