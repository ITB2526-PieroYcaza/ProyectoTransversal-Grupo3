-- ============================================================================
-- SCRIPT D'AUTOMATITZACIÓ REQUERIT EN LA PLANIFICACIÓ DE LA BD (InnovateTech)
-- ============================================================================
USE innovate_tech_db;

-- Aseguramos la activación del planificador de tareas en el motor de MySQL
SET GLOBAL event_scheduler = ON;

-- ----------------------------------------------------------------------------
-- 1. TRIGGER: REGISTRE D'ERRORS D'INTEGRITAT EN HISTORIAL (taula_avisos)
-- ----------------------------------------------------------------------------
-- Enunciat de la imatge: Quan s'intenta introduir un registre on 'data_hora_fi'
-- és anterior a 'data_hora_inici', a més de llançar l'error reglamentari,
-- s'ha d'inserir de manera automàtica un avís informatiu a 'taula_avisos'.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_auditoria_dates_trucada;

DELIMITER //

CREATE TRIGGER trg_auditoria_dates_trucada
BEFORE INSERT ON `registre_trucades`
FOR EACH ROW
BEGIN
    -- Comprovació de la incoherència de dates
    IF NEW.`data_hora_fi` < NEW.`data_hora_inici` THEN
        
        -- Inserim el log detallat en la taula de seguretat del sistema
        INSERT INTO `taula_avisos` (
            `usuari_mysql`, 
            `taula_afectada`, 
            `operacio_intentada`, 
            `descripcio_error`
        ) VALUES (
            USER(), 
            'registre_trucades', 
            'INSERT', 
            CONCAT('Intent d''inserció de trucada fallida. Data inici (', NEW.`data_hora_inici`, ') posterior a data fi (', NEW.`data_hora_fi`, '). Usuari origen: ', NEW.`id_usuari_origen`)
        );
        
        -- Bloquegem la transacció llançant l'error cap a l'aplicació web
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La data de fi de la trucada no pot ser anterior a la d''inici. Avís registrat.';
        
    END IF;
END //

DELIMITER ;


-- ----------------------------------------------------------------------------
-- 2. TRIGGER: CONTROL AUTOMÀTIC DE LES QUOTES DE TRUCADES (Consum diari)
-- ----------------------------------------------------------------------------
-- Enunciat de la imatge: Cada vegada que es realitzi una trucada correctament, 
-- s'ha de sumar una unitat a 'trucades_consumides_avui' a la taula 'quotes_trucades'.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_incrementar_quota_diaria;

DELIMITER //

CREATE TRIGGER trg_incrementar_quota_diaria
AFTER INSERT ON `registre_trucades`
FOR EACH ROW
BEGIN
    -- Incrementem en 1 el comptador diari per a l'usuari que ha originat la trucada
    UPDATE `quotes_trucades`
    SET `trucades_consumides_avui` = `trucades_consumides_avui` + 1
    WHERE `id_usuari` = NEW.`id_usuari_origen`;
END //

DELIMITER ;


-- ----------------------------------------------------------------------------
-- 3. EVENT PROGRAMAT: RESET DIARI DE QUOTES DE VEUP
-- ----------------------------------------------------------------------------
-- Enunciat de la imatge: Esdeveniment encarregat de posar a 0 de forma diària
-- la columna 'trucades_consumides_avui' de tots els usuaris de l'empresa.
-- ----------------------------------------------------------------------------
DROP EVENT IF EXISTS evt_reset_diari_trucades;

DELIMITER //

CREATE EVENT evt_reset_diari_trucades
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURDATE() + INTERVAL 1 DAY, ' 00:00:00')
ON COMPLETION PRESERVE
DO
BEGIN
    -- Posem a zero la quota de trucades diàries de tota la plantilla
    UPDATE `quotes_trucades`
    SET `trucades_consumides_avui` = 0;
END //

DELIMITER ;
