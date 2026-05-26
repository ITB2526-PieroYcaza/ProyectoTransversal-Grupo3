-- ============================================================================
-- SCRIPT D'AUTOMATITZACIÓ I AUDITORIA DE LA BASE DE DADES (InnovateTech)
-- ============================================================================
USE innovate_tech_db;

SET GLOBAL event_scheduler = ON;


-- ----------------------------------------------------------------------------
-- 1. TRIGGER: CONTROL AUTOMÀTIC I ACUMULACIÓ DE QUOTES DIÀRIES I MENSUALS
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
-- 2. TRIGGER: BLOQUEIG AUTOMÀTIC D'USUARIS PER EXCÉS DE CONSUM DIARI
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
-- 3. EVENT: CÒPIA DE SEGURETAT DIÀRIA DEL SISTEMA (02:00 AM)
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
