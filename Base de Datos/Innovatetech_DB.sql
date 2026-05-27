-- ============================================================================
-- SCRIPT FINAL TODO-EN-UNO: SEGURIDAD, PERMISOS NATIVOS Y AUDITORÍA
-- Base de datos: innovate_tech_db | Host de usuarios: '%'
-- ============================================================================

USE `innovate_tech_db`;

-- ----------------------------------------------------------------------------
-- 1. CONFIGURACIÓN ESTRUCTURAL DE SEGURIDAD
-- ----------------------------------------------------------------------------
-- Forzamos MyISAM en la tabla de avisos para evitar que los ROLLBACK de InnoDB
-- borren los registros de auditoría cuando salta un SIGNAL 45000.
ALTER TABLE `taula_avisos` ENGINE = MyISAM;

-- ----------------------------------------------------------------------------
-- 2. LIMPIEZA Y ASIGNACIÓN DE PERMISOS NATIVOS (SGBD)
-- ----------------------------------------------------------------------------
-- Revocamos privilegios previos para asegurar un despliegue limpio
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'vendes'@'%', 'administracio'@'%', 'treballador'@'%';

-- --- PERMISOS PARA EL ROL: 'vendes' ---
-- SELECTs estrictos según matriz de lectura
GRANT SELECT ON `innovate_tech_db`.`clients` TO 'vendes'@'%';
GRANT SELECT ON `innovate_tech_db`.`comandes` TO 'vendes'@'%';
GRANT SELECT ON `innovate_tech_db`.`productes` TO 'vendes'@'%';
GRANT SELECT ON `innovate_tech_db`.`cistell` TO 'vendes'@'%';
GRANT SELECT ON `innovate_tech_db`.`registre_trucades` TO 'vendes'@'%';
-- 'vendes' necesita poder hacer INSERT en taula_avisos para dejar log
GRANT INSERT ON `innovate_tech_db`.`taula_avisos` TO 'vendes'@'%';
-- Truco de Auditoría: Permitimos escrituras globales para que la consulta pase la 
-- capa nativa del SGBD y llegue al TRIGGER antes de ser bloqueada.
GRANT INSERT, UPDATE, DELETE ON `innovate_tech_db`.* TO 'vendes'@'%';

-- --- PERMISOS PARA EL ROL: 'administracio' ---
GRANT SELECT ON `innovate_tech_db`.`empleats` TO 'administracio'@'%';
GRANT SELECT ON `innovate_tech_db`.`nominas` TO 'administracio'@'%';
GRANT SELECT ON `innovate_tech_db`.`departaments` TO 'administracio'@'%';
GRANT SELECT ON `innovate_tech_db`.`grup_nivell` TO 'administracio'@'%';
GRANT INSERT ON `innovate_tech_db`.`taula_avisos` TO 'administracio'@'%';
GRANT INSERT, UPDATE, DELETE ON `innovate_tech_db`.* TO 'administracio'@'%';

-- --- PERMISOS PARA EL ROL: 'treballador' ---
GRANT SELECT ON `innovate_tech_db`.`productes` TO 'treballador'@'%';
GRANT SELECT ON `innovate_tech_db`.`cataleg_videos` TO 'treballador'@'%';
GRANT SELECT ON `innovate_tech_db`.`registre_trucades` TO 'treballador'@'%';
GRANT INSERT ON `innovate_tech_db`.`taula_avisos` TO 'treballador'@'%';
GRANT INSERT, UPDATE, DELETE ON `innovate_tech_db`.* TO 'treballador'@'%';

FLUSH PRIVILEGES;

-- ----------------------------------------------------------------------------
-- 3. DESPLIEGUE DE TRIGGERS DE CONTROL Y AUDITORÍA PERSONALIZADA
-- ----------------------------------------------------------------------------
DELIMITER $$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `rols_ldap`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_rols_ldap`;$$
CREATE TRIGGER `tg_b_insert_rols_ldap` BEFORE INSERT ON `rols_ldap` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'rols_ldap', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en rols_ldap.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_rols_ldap`;$$
CREATE TRIGGER `tg_b_update_rols_ldap` BEFORE UPDATE ON `rols_ldap` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'rols_ldap', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en rols_ldap.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_rols_ldap`;$$
CREATE TRIGGER `tg_b_delete_rols_ldap` BEFORE DELETE ON `rols_ldap` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'rols_ldap', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en rols_ldap.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `departaments`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_departaments`;$$
CREATE TRIGGER `tg_b_insert_departaments` BEFORE INSERT ON `departaments` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'departaments', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en departaments.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_departaments`;$$
CREATE TRIGGER `tg_b_update_departaments` BEFORE UPDATE ON `departaments` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'departaments', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en departaments.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_departaments`;$$
CREATE TRIGGER `tg_b_delete_departaments` BEFORE DELETE ON `departaments` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'departaments', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en departaments.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `grup_nivell`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_grup_nivell`;$$
CREATE TRIGGER `tg_b_insert_grup_nivell` BEFORE INSERT ON `grup_nivell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'grup_nivell', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en grup_nivell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_grup_nivell`;$$
CREATE TRIGGER `tg_b_update_grup_nivell` BEFORE UPDATE ON `grup_nivell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'grup_nivell', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en grup_nivell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_grup_nivell`;$$
CREATE TRIGGER `tg_b_delete_grup_nivell` BEFORE DELETE ON `grup_nivell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'grup_nivell', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en grup_nivell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `empleats`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_empleats`;$$
CREATE TRIGGER `tg_b_insert_empleats` BEFORE INSERT ON `empleats` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'empleats', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en empleats.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_empleats`;$$
CREATE TRIGGER `tg_b_update_empleats` BEFORE UPDATE ON `empleats` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'empleats', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en empleats.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_empleats`;$$
CREATE TRIGGER `tg_b_delete_empleats` BEFORE DELETE ON `empleats` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'empleats', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en empleats.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `nominas`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_nominas`;$$
CREATE TRIGGER `tg_b_insert_nominas` BEFORE INSERT ON `nominas` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'nominas', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en nominas.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_nominas`;$$
CREATE TRIGGER `tg_b_update_nominas` BEFORE UPDATE ON `nominas` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'nominas', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en nominas.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_nominas`;$$
CREATE TRIGGER `tg_b_delete_nominas` BEFORE DELETE ON `nominas` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'nominas', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en nominas.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `clients`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_clients`;$$
CREATE TRIGGER `tg_b_insert_clients` BEFORE INSERT ON `clients` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'clients', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en clients.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_clients`;$$
CREATE TRIGGER `tg_b_update_clients` BEFORE UPDATE ON `clients` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'clients', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en clients.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_clients`;$$
CREATE TRIGGER `tg_b_delete_clients` BEFORE DELETE ON `clients` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'clients', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en clients.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `productes`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_productes`;$$
CREATE TRIGGER `tg_b_insert_productes` BEFORE INSERT ON `productes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'productes', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en productes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_productes`;$$
CREATE TRIGGER `tg_b_update_productes` BEFORE UPDATE ON `productes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'productes', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en productes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_productes`;$$
CREATE TRIGGER `tg_b_delete_productes` BEFORE DELETE ON `productes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'productes', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en productes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `comandes`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_comandes`;$$
CREATE TRIGGER `tg_b_insert_comandes` BEFORE INSERT ON `comandes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'comandes', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en comandes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_comandes`;$$
CREATE TRIGGER `tg_b_update_comandes` BEFORE UPDATE ON `comandes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'comandes', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en comandes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_comandes`;$$
CREATE TRIGGER `tg_b_delete_comandes` BEFORE DELETE ON `comandes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'comandes', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en comandes.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `cistell`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_cistell`;$$
CREATE TRIGGER `tg_b_insert_cistell` BEFORE INSERT ON `cistell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cistell', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en cistell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_cistell`;$$
CREATE TRIGGER `tg_b_update_cistell` BEFORE UPDATE ON `cistell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cistell', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en cistell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_cistell`;$$
CREATE TRIGGER `tg_b_delete_cistell` BEFORE DELETE ON `cistell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cistell', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en cistell.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `configuracio_qualitat`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_configuracio_qualitat`;$$
CREATE TRIGGER `tg_b_insert_configuracio_qualitat` BEFORE INSERT ON `configuracio_qualitat` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'configuracio_qualitat', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en configuracio_qualitat.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_configuracio_qualitat`;$$
CREATE TRIGGER `tg_b_update_configuracio_qualitat` BEFORE UPDATE ON `configuracio_qualitat` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'configuracio_qualitat', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en configuracio_qualitat.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_configuracio_qualitat`;$$
CREATE TRIGGER `tg_b_delete_configuracio_qualitat` BEFORE DELETE ON `configuracio_qualitat` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'configuracio_qualitat', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en configuracio_qualitat.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `usuaris_sistema`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_usuaris_sistema`;$$
CREATE TRIGGER `tg_b_insert_usuaris_sistema` BEFORE INSERT ON `usuaris_sistema` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'usuaris_sistema', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en usuaris_sistema.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_usuaris_sistema`;$$
CREATE TRIGGER `tg_b_update_usuaris_sistema` BEFORE UPDATE ON `usuaris_sistema` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'usuaris_sistema', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en usuaris_sistema.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_usuaris_sistema`;$$
CREATE TRIGGER `tg_b_delete_usuaris_sistema` BEFORE DELETE ON `usuaris_sistema` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'usuaris_sistema', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en usuaris_sistema.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `servidors_videoconferencia`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_servidors_videoconferencia`;$$
CREATE TRIGGER `tg_b_insert_servidors_videoconferencia` BEFORE INSERT ON `servidors_videoconferencia` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'servidors_videoconferencia', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en servidors_videoconferencia.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_servidors_videoconferencia`;$$
CREATE TRIGGER `tg_b_update_servidors_videoconferencia` BEFORE UPDATE ON `servidors_videoconferencia` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'servidors_videoconferencia', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en servidors_videoconferencia.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_servidors_videoconferencia`;$$
CREATE TRIGGER `tg_b_delete_servidors_videoconferencia` BEFORE DELETE ON `servidors_videoconferencia` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'servidors_videoconferencia', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en servidors_videoconferencia.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `registre_trucades`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_registre_trucades`;$$
CREATE TRIGGER `tg_b_insert_registre_trucades` BEFORE INSERT ON `registre_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'registre_trucades', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en registre_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_registre_trucades`;$$
CREATE TRIGGER `tg_b_update_registre_trucades` BEFORE UPDATE ON `registre_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'registre_trucades', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en registre_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_registre_trucades`;$$
CREATE TRIGGER `tg_b_delete_registre_trucades` BEFORE DELETE ON `registre_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'registre_trucades', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en registre_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `cataleg_videos`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_cataleg_videos`;$$
CREATE TRIGGER `tg_b_insert_cataleg_videos` BEFORE INSERT ON `cataleg_videos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cataleg_videos', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en cataleg_videos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_cataleg_videos`;$$
CREATE TRIGGER `tg_b_update_cataleg_videos` BEFORE UPDATE ON `cataleg_videos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cataleg_videos', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en cataleg_videos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_cataleg_videos`;$$
CREATE TRIGGER `tg_b_delete_cataleg_videos` BEFORE DELETE ON `cataleg_videos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cataleg_videos', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en cataleg_videos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `mesures_amplada_banda`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_mesures_amplada_banda`;$$
CREATE TRIGGER `tg_b_insert_mesures_amplada_banda` BEFORE INSERT ON `mesures_amplada_banda` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'mesures_amplada_banda', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en mesures_amplada_banda.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_mesures_amplada_banda`;$$
CREATE TRIGGER `tg_b_update_mesures_amplada_banda` BEFORE UPDATE ON `mesures_amplada_banda` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'mesures_amplada_banda', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en mesures_amplada_banda.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_mesures_amplada_banda`;$$
CREATE TRIGGER `tg_b_delete_mesures_amplada_banda` BEFORE DELETE ON `mesures_amplada_banda` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'mesures_amplada_banda', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en mesures_amplada_banda.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `taula_avisos`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_taula_avisos`;$$
CREATE TRIGGER `tg_b_insert_taula_avisos` BEFORE INSERT ON `taula_avisos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes', 'administracio', 'treballador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_taula_avisos`;$$
CREATE TRIGGER `tg_b_update_taula_avisos` BEFORE UPDATE ON `taula_avisos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_taula_avisos`;$$
CREATE TRIGGER `tg_b_delete_taula_avisos` BEFORE DELETE ON `taula_avisos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `quotes_trucades`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_quotes_trucades`;$$
CREATE TRIGGER `tg_b_insert_quotes_trucades` BEFORE INSERT ON `quotes_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'quotes_trucades', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en quotes_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_quotes_trucades`;$$
CREATE TRIGGER `tg_b_update_quotes_trucades` BEFORE UPDATE ON `quotes_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'quotes_trucades', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en quotes_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_quotes_trucades`;$$
CREATE TRIGGER `tg_b_delete_quotes_trucades` BEFORE DELETE ON `quotes_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'quotes_trucades', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en quotes_trucades.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

-- ============================================================================
-- TRIGGERS DE SEGURIDAD PARA LA TABLA: `control_backups`
-- ============================================================================
DROP TRIGGER IF EXISTS `tg_b_insert_control_backups`;$$
CREATE TRIGGER `tg_b_insert_control_backups` BEFORE INSERT ON `control_backups` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'control_backups', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de INSERT en control_backups.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_update_control_backups`;$$
CREATE TRIGGER `tg_b_update_control_backups` BEFORE UPDATE ON `control_backups` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'control_backups', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de UPDATE en control_backups.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_delete_control_backups`;$$
CREATE TRIGGER `tg_b_delete_control_backups` BEFORE DELETE ON `control_backups` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);
    SET v_role = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'control_backups', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos de DELETE en control_backups.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Permisos insuficients per a realitzar aquesta operació.';
    END IF;
END;$$

DELIMITER ;
