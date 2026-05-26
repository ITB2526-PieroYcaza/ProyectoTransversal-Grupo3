-- ============================================================================
-- SCRIPT D'AUTOMATITZACIÓ I AUDITORIA DE LA BASE DE DADES (InnovateTech)
-- ============================================================================
USE innovate_tech_db;

SET GLOBAL event_scheduler = ON;

-- ----------------------------------------------------------------------------
-- 1. SISTEMA DE TRIGGERS D'AUDITORIA GENERAL (TAULA_AVISOS)
-- Registra automàticament qualsevol INSERT, UPDATE o DELETE a les taules crítiques
-- ----------------------------------------------------------------------------

-- A) AUDITORIA PER A 'registre_trucades'
DROP TRIGGER IF EXISTS trg_audit_insert_trucades;
DELIMITER //
CREATE TRIGGER trg_audit_insert_trucades
AFTER INSERT ON `registre_trucades`
FOR EACH ROW
BEGIN
    INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
    VALUES (USER(), 'registre_trucades', 'INSERT', CONCAT('S\'ha registrat una nova trucada amb ID: ', NEW.id_trucada, ' entre els usuaris ', NEW.id_usuari_origen, ' i ', NEW.id_usuari_desti));
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg_audit_update_trucades;
DELIMITER //
CREATE TRIGGER trg_audit_update_trucades
AFTER UPDATE ON `registre_trucades`
FOR EACH ROW
BEGIN
    INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
    VALUES (USER(), 'registre_trucades', 'UPDATE', CONCAT('S\'ha modificat la trucada ID: ', OLD.id_trucada, '. Durada anterior: ', OLD.durada_segons, 's, Nova durada: ', NEW.durada_segons, 's.'));
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg_audit_delete_trucades;
DELIMITER //
CREATE TRIGGER trg_audit_delete_trucades
AFTER DELETE ON `registre_trucades`
FOR EACH ROW
BEGIN
    INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
    VALUES (USER(), 'registre_trucades', 'DELETE', CONCAT('ALERTA: S\'ha eliminat el registre de trucada ID: ', OLD.id_trucada, ' de l\'usuari origen ', OLD.id_usuari_origen));
END //
DELIMITER ;


-- B) AUDITORIA PER A 'usuaris_sistema'
DROP TRIGGER IF EXISTS trg_audit_insert_usuaris;
DELIMITER //
CREATE TRIGGER trg_audit_insert_usuaris
AFTER INSERT ON `usuaris_sistema`
FOR EACH ROW
BEGIN
    INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
    VALUES (USER(), 'usuaris_sistema', 'INSERT', CONCAT('Nou usuari creat: ', NEW.nom_complet, ' (Correu: ', NEW.correu_electronic, ') amb Rol GID: ', NEW.gid_rol));
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg_audit_update_usuaris;
DELIMITER //
CREATE TRIGGER trg_audit_update_usuaris
AFTER UPDATE ON `usuaris_sistema`
FOR EACH ROW
BEGIN
    INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
    VALUES (USER(), 'usuaris_sistema', 'UPDATE', CONCAT('Usuari ID ', OLD.id_usuari, ' modificat. Estat anterior: ', OLD.estat, ', Nou estat: ', NEW.estat));
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg_audit_delete_usuaris;
DELIMITER //
CREATE TRIGGER trg_audit_delete_usuaris
AFTER DELETE ON `usuaris_sistema`
FOR EACH ROW
BEGIN
    INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
    VALUES (USER(), 'usuaris_sistema', 'DELETE', CONCAT('ALERTA: S\'ha suprimit l\'usuari ', OLD.nom_complet, ' amb correu ', OLD.correu_electronic));
END //
DELIMITER ;


-- ----------------------------------------------------------------------------
-- 2. TRIGGER: CONTROL AUTOMÀTIC I ACUMULACIÓ DE QUOTES DIÀRIES I MENSUALS
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_incrementar_quota_diaria;
DELIMITER //
CREATE TRIGGER trg_incrementar_quota_diaria
AFTER INSERT ON `registre_trucades`
FOR EACH ROW
BEGIN
    UPDATE `quotes_trucades`
    SET `trucades_consumides_avui` = `trucades_consumides_avui` + 1,
        `minuts_consumits_mes` = `minuts_consumits_mes` + TIMESTAMPDIFF(MINUTE, NEW.`data_hora_inici`, NEW.`data_hora_fi`)
    WHERE `id_usuari` = NEW.`id_usuari_origen`;
END //
DELIMITER ;


-- ----------------------------------------------------------------------------
-- 3. TRIGGER: BLOQUEIG AUTOMÀTIC D'USUARIS PER EXCÉS DE CONSUM DIARI
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_bloqueig_exces_trucades;
DELIMITER //
CREATE TRIGGER trg_bloqueig_exces_trucades
AFTER UPDATE ON `quotes_trucades`
FOR EACH ROW
BEGIN
    IF NEW.`trucades_consumides_avui` >= NEW.`trucades_diaries_max` AND OLD.`trucades_consumides_avui` < NEW.`trucades_diaries_max` THEN
        
        UPDATE `usuaris_sistema`
        SET `estat` = 'bloquejat'
        WHERE `id_usuari` = NEW.`id_usuari`;
        
        INSERT INTO `taula_avisos` (
            `usuari_mysql`, 
            `taula_afectada`, 
            `operacio_intentada`, 
            `descripcio_error`
        ) VALUES (
            'SYSTEM_TRIGGER', 
            'usuaris_sistema', 
            'UPDATE', 
            CONCAT('L\'usuari amb ID ', NEW.`id_usuari`, ' ha estat bloquejat automàticament per superar el límit diari permès.')
        );
    END IF;
END //
DELIMITER ;


-- ----------------------------------------------------------------------------
-- 4. EVENT: CÒPIA DE SEGURETAT DIÀRIA DEL SISTEMA (02:00 AM)
-- ----------------------------------------------------------------------------
DROP EVENT IF EXISTS evt_backup_diari_sistema;
DELIMITER //
CREATE EVENT evt_backup_diari_sistema
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURDATE() + INTERVAL 1 DAY, ' 02:00:00')
ON COMPLETION PRESERVE
DO
BEGIN
    DECLARE ruta_fitxer VARCHAR(255);
    SET ruta_fitxer = CONCAT('/var/backups/innovatetech/backup_trucades_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'), '.csv');

    BEGIN
        SET @sql = CONCAT('SELECT * FROM `registre_trucades` INTO OUTFILE ''', ruta_fitxer, ''' FIELDS TERMINATED BY '','' LINES TERMINATED BY ''\\n''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        INSERT INTO `control_backups` (`taules_incloses`, `resultat`)
        VALUES ('registre_trucades', 'correcte');
    END;
END //
DELIMITER ;
