-- ============================================================================
-- SCRIPT FINAL TODO-EN-UNO DE SEGURIDAD INTEGRAL Y AUDITORÍA
-- Base de datos: innovate_tech_db | Soporte Localhost y Remoto (%)
-- ============================================================================

USE `innovate_tech_db`;

-- ----------------------------------------------------------------------------
-- 1. CONFIGURACIÓN ESTRUCTURAL DE SEGURIDAD
-- ----------------------------------------------------------------------------
-- Forzamos MyISAM en la tabla de avisos para evitar que los ROLLBACK de InnoDB
-- borren los registros de auditoría cuando salta un SIGNAL 45000.
ALTER TABLE `taula_avisos` ENGINE = MyISAM;

-- ----------------------------------------------------------------------------
-- 2. LIMPIEZA Y REASIGNACIÓN DE PERMISOS NATIVOS (SGBD)
-- ----------------------------------------------------------------------------
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'vendes'@'%', 'administracio'@'%', 'treballador'@'%';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'vendes'@'localhost', 'administracio'@'localhost', 'treballador'@'localhost';

-- --- PERMISOS PARA EL ROL: 'vendes' (Local y Remoto) ---
GRANT SELECT ON `innovate_tech_db`.`clients` TO 'vendes'@'%', 'vendes'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`comandes` TO 'vendes'@'%', 'vendes'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`productes` TO 'vendes'@'%', 'vendes'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`cistell` TO 'vendes'@'%', 'vendes'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`registre_trucades` TO 'vendes'@'%', 'vendes'@'localhost';
GRANT INSERT ON `innovate_tech_db`.`taula_avisos` TO 'vendes'@'%', 'vendes'@'localhost';
GRANT INSERT, UPDATE, DELETE ON `innovate_tech_db`.* TO 'vendes'@'%', 'vendes'@'localhost';

-- --- PERMISOS PARA EL ROL: 'administracio' (Local y Remoto) ---
GRANT SELECT ON `innovate_tech_db`.`empleats` TO 'administracio'@'%', 'administracio'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`nominas` TO 'administracio'@'%', 'administracio'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`departaments` TO 'administracio'@'%', 'administracio'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`grup_nivell` TO 'administracio'@'%', 'administracio'@'localhost';
GRANT INSERT ON `innovate_tech_db`.`taula_avisos` TO 'administracio'@'%', 'administracio'@'localhost';
GRANT INSERT, UPDATE, DELETE ON `innovate_tech_db`.* TO 'administracio'@'%', 'administracio'@'localhost';

-- --- PERMISOS PARA EL ROL: 'treballador' (Local y Remoto) ---
GRANT SELECT ON `innovate_tech_db`.`productes` TO 'treballador'@'%', 'treballador'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`cataleg_videos` TO 'treballador'@'%', 'treballador'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`configuracio_qualitat` TO 'treballador'@'%', 'treballador'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`quotes_trucades` TO 'treballador'@'%', 'treballador'@'localhost';
GRANT SELECT ON `innovate_tech_db`.`registre_trucades` TO 'treballador'@'%', 'treballador'@'localhost';
GRANT INSERT ON `innovate_tech_db`.`taula_avisos` TO 'treballador'@'%', 'treballador'@'localhost';
GRANT INSERT, UPDATE, DELETE ON `innovate_tech_db`.* TO 'treballador'@'%', 'treballador'@'localhost';

FLUSH PRIVILEGES;

-- ----------------------------------------------------------------------------
-- 3. DESPLIEGUE SEGURO DE TRIGGERS PERMUTADOS (54 TRIGGERS)
-- ----------------------------------------------------------------------------
DELIMITER $$

-- ============================================================================
-- 1. TABLA: rols_ldap
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_rols_ldap`;$$
CREATE TRIGGER `tg_b_ins_rols_ldap` BEFORE INSERT ON `rols_ldap` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'rols_ldap', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en rols_ldap.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_rols_ldap`;$$
CREATE TRIGGER `tg_b_upd_rols_ldap` BEFORE UPDATE ON `rols_ldap` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'rols_ldap', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en rols_ldap.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_rols_ldap`;$$
CREATE TRIGGER `tg_b_del_rols_ldap` BEFORE DELETE ON `rols_ldap` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'rols_ldap', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en rols_ldap.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 2. TABLA: departaments
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_departaments`;$$
CREATE TRIGGER `tg_b_ins_departaments` BEFORE INSERT ON `departaments` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'departaments', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en departaments.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_departaments`;$$
CREATE TRIGGER `tg_b_upd_departaments` BEFORE UPDATE ON `departaments` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'departaments', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en departaments.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_departaments`;$$
CREATE TRIGGER `tg_b_del_departaments` BEFORE DELETE ON `departaments` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'departaments', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en departaments.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 3. TABLA: grup_nivell
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_grup_nivell`;$$
CREATE TRIGGER `tg_b_ins_grup_nivell` BEFORE INSERT ON `grup_nivell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'grup_nivell', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en grup_nivell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_grup_nivell`;$$
CREATE TRIGGER `tg_b_upd_grup_nivell` BEFORE UPDATE ON `grup_nivell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'grup_nivell', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en grup_nivell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_grup_nivell`;$$
CREATE TRIGGER `tg_b_del_grup_nivell` BEFORE DELETE ON `grup_nivell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'grup_nivell', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en grup_nivell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 4. TABLA: empleats
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_empleats`;$$
CREATE TRIGGER `tg_b_ins_empleats` BEFORE INSERT ON `empleats` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'empleats', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en empleats.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_empleats`;$$
CREATE TRIGGER `tg_b_upd_empleats` BEFORE UPDATE ON `empleats` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'empleats', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en empleats.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_empleats`;$$
CREATE TRIGGER `tg_b_del_empleats` BEFORE DELETE ON `empleats` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'empleats', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en empleats.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 5. TABLA: nominas
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_nominas`;$$
CREATE TRIGGER `tg_b_ins_nominas` BEFORE INSERT ON `nominas` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'nominas', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en nominas.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_nominas`;$$
CREATE TRIGGER `tg_b_upd_nominas` BEFORE UPDATE ON `nominas` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'nominas', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en nominas.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_nominas`;$$
CREATE TRIGGER `tg_b_del_nominas` BEFORE DELETE ON `nominas` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'nominas', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en nominas.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 6. TABLA: clients
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_clients`;$$
CREATE TRIGGER `tg_b_ins_clients` BEFORE INSERT ON `clients` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'clients', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en clients.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_clients`;$$
CREATE TRIGGER `tg_b_upd_clients` BEFORE UPDATE ON `clients` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'clients', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en clients.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_clients`;$$
CREATE TRIGGER `tg_b_del_clients` BEFORE DELETE ON `clients` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'clients', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en clients.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 7. TABLA: productes
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_productes`;$$
CREATE TRIGGER `tg_b_ins_productes` BEFORE INSERT ON `productes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'productes', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en productes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_productes`;$$
CREATE TRIGGER `tg_b_upd_productes` BEFORE UPDATE ON `productes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'productes', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en productes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_productes`;$$
CREATE TRIGGER `tg_b_del_productes` BEFORE DELETE ON `productes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'productes', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en productes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 8. TABLA: comandes
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_comandes`;$$
CREATE TRIGGER `tg_b_ins_comandes` BEFORE INSERT ON `comandes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'comandes', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en comandes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_comandes`;$$
CREATE TRIGGER `tg_b_upd_comandes` BEFORE UPDATE ON `comandes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'comandes', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en comandes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_comandes`;$$
CREATE TRIGGER `tg_b_del_comandes` BEFORE DELETE ON `comandes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'comandes', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en comandes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 9. TABLA: cistell
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_cistell`;$$
CREATE TRIGGER `tg_b_ins_cistell` BEFORE INSERT ON `cistell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cistell', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en cistell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_cistell`;$$
CREATE TRIGGER `tg_b_upd_cistell` BEFORE UPDATE ON `cistell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cistell', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en cistell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_cistell`;$$
CREATE TRIGGER `tg_b_del_cistell` BEFORE DELETE ON `cistell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cistell', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en cistell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 10. TABLA: configuracio_qualitat
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_configuracio_qualitat`;$$
CREATE TRIGGER `tg_b_ins_configuracio_qualitat` BEFORE INSERT ON `configuracio_qualitat` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'configuracio_qualitat', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en configuracio_qualitat.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_configuracio_qualitat`;$$
CREATE TRIGGER `tg_b_upd_configuracio_qualitat` BEFORE UPDATE ON `configuracio_qualitat` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'configuracio_qualitat', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en configuracio_qualitat.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_configuracio_qualitat`;$$
CREATE TRIGGER `tg_b_del_configuracio_qualitat` BEFORE DELETE ON `configuracio_qualitat` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'configuracio_qualitat', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en configuracio_qualitat.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 11. TABLA: usuaris_sistema
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_usuaris_sistema`;$$
CREATE TRIGGER `tg_b_ins_usuaris_sistema` BEFORE INSERT ON `usuaris_sistema` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'usuaris_sistema', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en usuaris_sistema.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_usuaris_sistema`;$$
CREATE TRIGGER `tg_b_upd_usuaris_sistema` BEFORE UPDATE ON `usuaris_sistema` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'usuaris_sistema', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en usuaris_sistema.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_usuaris_sistema`;$$
CREATE TRIGGER `tg_b_del_usuaris_sistema` BEFORE DELETE ON `usuaris_sistema` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'usuaris_sistema', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en usuaris_sistema.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 12. TABLA: servidors_videoconferencia
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_servidors_videoconferencia`;$$
CREATE TRIGGER `tg_b_ins_servidors_videoconferencia` BEFORE INSERT ON `servidors_videoconferencia` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'servidors_videoconferencia', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en servidors_videoconferencia.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_servidors_videoconferencia`;$$
CREATE TRIGGER `tg_b_upd_servidors_videoconferencia` BEFORE UPDATE ON `servidors_videoconferencia` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'servidors_videoconferencia', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en servidors_videoconferencia.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_servidors_videoconferencia`;$$
CREATE TRIGGER `tg_b_del_servidors_videoconferencia` BEFORE DELETE ON `servidors_videoconferencia` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'servidors_videoconferencia', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en servidors_videoconferencia.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 13. TABLA: registre_trucades
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_registre_trucades`;$$
CREATE TRIGGER `tg_b_ins_registre_trucades` BEFORE INSERT ON `registre_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'registre_trucades', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en registre_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_registre_trucades`;$$
CREATE TRIGGER `tg_b_upd_registre_trucades` BEFORE UPDATE ON `registre_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'registre_trucades', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en registre_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_registre_trucades`;$$
CREATE TRIGGER `tg_b_del_registre_trucades` BEFORE DELETE ON `registre_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'registre_trucades', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en registre_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 14. TABLA: cataleg_videos
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_cataleg_videos`;$$
CREATE TRIGGER `tg_b_ins_cataleg_videos` BEFORE INSERT ON `cataleg_videos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cataleg_videos', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en cataleg_videos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_cataleg_videos`;$$
CREATE TRIGGER `tg_b_upd_cataleg_videos` BEFORE UPDATE ON `cataleg_videos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cataleg_videos', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en cataleg_videos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_cataleg_videos`;$$
CREATE TRIGGER `tg_b_del_cataleg_videos` BEFORE DELETE ON `cataleg_videos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cataleg_videos', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en cataleg_videos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 15. TABLA: mesures_amplada_banda
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_mesures_amplada_banda`;$$
CREATE TRIGGER `tg_b_ins_mesures_amplada_banda` BEFORE INSERT ON `mesures_amplada_banda` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'mesures_amplada_banda', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en mesures_amplada_banda.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_mesures_amplada_banda`;$$
CREATE TRIGGER `tg_b_upd_mesures_amplada_banda` BEFORE UPDATE ON `mesures_amplada_banda` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'mesures_amplada_banda', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en mesures_amplada_banda.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_mesures_amplada_banda`;$$
CREATE TRIGGER `tg_b_del_mesures_amplada_banda` BEFORE DELETE ON `mesures_amplada_banda` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'mesures_amplada_banda', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en mesures_amplada_banda.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 16. TABLA: taula_avisos (Excluida de auto-registro para prevenir bucle infinito)
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_taula_avisos`;$$
CREATE TRIGGER `tg_b_ins_taula_avisos` BEFORE INSERT ON `taula_avisos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    -- Permitido INSERT para auditoría, bloqueamos si no es un rol contemplado externamente
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes', 'administracio', 'treballador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_taula_avisos`;$$
CREATE TRIGGER `tg_b_upd_taula_avisos` BEFORE UPDATE ON `taula_avisos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients. Modificación de logs prohibida.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_taula_avisos`;$$
CREATE TRIGGER `tg_b_del_taula_avisos` BEFORE DELETE ON `taula_avisos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients. Borrado de logs prohibido.';
    END IF;
END;$$

-- ============================================================================
-- 17. TABLA: quotes_trucades
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_quotes_trucades`;$$
CREATE TRIGGER `tg_b_ins_quotes_trucades` BEFORE INSERT ON `quotes_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'quotes_trucades', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en quotes_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_quotes_trucades`;$$
CREATE TRIGGER `tg_b_upd_quotes_trucades` BEFORE UPDATE ON `quotes_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'quotes_trucades', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en quotes_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_quotes_trucades`;$$
CREATE TRIGGER `tg_b_del_quotes_trucades` BEFORE DELETE ON `quotes_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'quotes_trucades', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en quotes_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- 18. TABLA: control_backups
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_ins_control_backups`;$$
CREATE TRIGGER `tg_b_ins_control_backups` BEFORE INSERT ON `control_backups` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'control_backups', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en control_backups.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_control_backups`;$$
CREATE TRIGGER `tg_b_upd_control_backups` BEFORE UPDATE ON `control_backups` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'control_backups', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en control_backups.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_control_backups`;$$
CREATE TRIGGER `tg_b_del_control_backups` BEFORE DELETE ON `control_backups` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'control_backups', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en control_backups.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients per a aquesta operació.';
    END IF;
END;$$

DELIMITER ;
