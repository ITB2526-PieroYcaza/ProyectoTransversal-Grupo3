-- ============================================================================
-- SCRIPT DE SEGURIDAD TOTAL (REPLICADO PARA TODA LA BD)
-- Todos los usuarios están en '%' - Permiso Global + Bloqueo por Trigger
-- ============================================================================

USE `innovate_tech_db`;

-- ----------------------------------------------------------------------------
-- 1. MOTOR DE AUDITORÍA (Evita pérdidas por ROLLBACK)
-- ----------------------------------------------------------------------------
ALTER TABLE `taula_avisos` ENGINE = MyISAM;

-- ----------------------------------------------------------------------------
-- 2. ASIGNACIÓN DE PERMISOS NATIVOS GLOBALES (El truco que funciona)
-- ----------------------------------------------------------------------------
-- Primero limpiamos cualquier residuo anterior del host localhost que creé mal
DROP USER IF EXISTS 'vendes'@'localhost', 'administracio'@'localhost', 'treballador'@'localhost';

-- Reseteamos los usuarios reales de '%'
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'vendes'@'%', 'administracio'@'%', 'treballador'@'%';

-- Otorgamos acceso de lectura a sus tablas correspondientes
GRANT SELECT ON `innovate_tech_db`.`clients` TO 'vendes'@'%';
GRANT SELECT ON `innovate_tech_db`.`comandes` TO 'vendes'@'%';
GRANT SELECT ON `innovate_tech_db`.`productes` TO 'vendes'@'%';
GRANT SELECT ON `innovate_tech_db`.`cistell` TO 'vendes'@'%';
GRANT SELECT ON `innovate_tech_db`.`registre_trucades` TO 'vendes'@'%';

GRANT SELECT ON `innovate_tech_db`.`empleats` TO 'administracio'@'%';
GRANT SELECT ON `innovate_tech_db`.`nominas` TO 'administracio'@'%';
GRANT SELECT ON `innovate_tech_db`.`departaments` TO 'administracio'@'%';
GRANT SELECT ON `innovate_tech_db`.`grup_nivell` TO 'administracio'@'%';

GRANT SELECT ON `innovate_tech_db`.`productes` TO 'treballador'@'%';
GRANT SELECT ON `innovate_tech_db`.`cataleg_videos` TO 'treballador'@'%';
GRANT SELECT ON `innovate_tech_db`.`configuracio_qualitat` TO 'treballador'@'%';
GRANT SELECT ON `innovate_tech_db`.`quotes_trucades` TO 'treballador'@'%';
GRANT SELECT ON `innovate_tech_db`.`registre_trucades` TO 'treballador'@'%';

-- Permiso crucial: Permitir escribir en la tabla de avisos
GRANT INSERT ON `innovate_tech_db`.`taula_avisos` TO 'vendes'@'%', 'administracio'@'%', 'treballador'@'%';

-- EL TRUCO MAESTRO: Les damos permiso total de escritura nativo en la BD.
-- Esto hace que MySQL NUNCA devuelva el Error 1142 y deje que el TRIGGER tome el control.
GRANT INSERT, UPDATE, DELETE ON `innovate_tech_db`.* TO 'vendes'@'%', 'administracio'@'%', 'treballador'@'%';

FLUSH PRIVILEGES;

-- ----------------------------------------------------------------------------
-- 3. TRIGGERS DE CONTROL DE ACCESO (54 TRIGGERS EN TOTAL)
-- ----------------------------------------------------------------------------
DELIMITER $$

-- === 1. rols_ldap ===
DROP TRIGGER IF EXISTS `tg_b_ins_rols_ldap`;$$
CREATE TRIGGER `tg_b_ins_rols_ldap` BEFORE INSERT ON `rols_ldap` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'rols_ldap', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_rols_ldap`;$$
CREATE TRIGGER `tg_b_upd_rols_ldap` BEFORE UPDATE ON `rols_ldap` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'rols_ldap', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_rols_ldap`;$$
CREATE TRIGGER `tg_b_del_rols_ldap` BEFORE DELETE ON `rols_ldap` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'rols_ldap', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 2. departaments ===
DROP TRIGGER IF EXISTS `tg_b_ins_departaments`;$$
CREATE TRIGGER `tg_b_ins_departaments` BEFORE INSERT ON `departaments` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'departaments', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_departaments`;$$
CREATE TRIGGER `tg_b_upd_departaments` BEFORE UPDATE ON `departaments` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'departaments', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_departaments`;$$
CREATE TRIGGER `tg_b_del_departaments` BEFORE DELETE ON `departaments` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'departaments', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 3. grup_nivell ===
DROP TRIGGER IF EXISTS `tg_b_ins_grup_nivell`;$$
CREATE TRIGGER `tg_b_ins_grup_nivell` BEFORE INSERT ON `grup_nivell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'grup_nivell', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_grup_nivell`;$$
CREATE TRIGGER `tg_b_upd_grup_nivell` BEFORE UPDATE ON `grup_nivell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'grup_nivell', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_grup_nivell`;$$
CREATE TRIGGER `tg_b_del_grup_nivell` BEFORE DELETE ON `grup_nivell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'grup_nivell', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 4. empleats ===
DROP TRIGGER IF EXISTS `tg_b_ins_empleats`;$$
CREATE TRIGGER `tg_b_ins_empleats` BEFORE INSERT ON `empleats` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'empleats', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_empleats`;$$
CREATE TRIGGER `tg_b_upd_empleats` BEFORE UPDATE ON `empleats` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'empleats', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_empleats`;$$
CREATE TRIGGER `tg_b_del_empleats` BEFORE DELETE ON `empleats` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'empleats', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 5. nominas ===
DROP TRIGGER IF EXISTS `tg_b_ins_nominas`;$$
CREATE TRIGGER `tg_b_ins_nominas` BEFORE INSERT ON `nominas` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'nominas', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_nominas`;$$
CREATE TRIGGER `tg_b_upd_nominas` BEFORE UPDATE ON `nominas` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'nominas', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_nominas`;$$
CREATE TRIGGER `tg_b_del_nominas` BEFORE DELETE ON `nominas` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'nominas', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 6. clients ===
DROP TRIGGER IF EXISTS `tg_b_ins_clients`;$$
CREATE TRIGGER `tg_b_ins_clients` BEFORE INSERT ON `clients` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'clients', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_clients`;$$
CREATE TRIGGER `tg_b_upd_clients` BEFORE UPDATE ON `clients` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'clients', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_clients`;$$
CREATE TRIGGER `tg_b_del_clients` BEFORE DELETE ON `clients` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'clients', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 7. productes ===
DROP TRIGGER IF EXISTS `tg_b_ins_productes`;$$
CREATE TRIGGER `tg_b_ins_productes` BEFORE INSERT ON `productes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'productes', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_productes`;$$
CREATE TRIGGER `tg_b_upd_productes` BEFORE UPDATE ON `productes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'productes', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_productes`;$$
CREATE TRIGGER `tg_b_del_productes` BEFORE DELETE ON `productes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'productes', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 8. comandes ===
DROP TRIGGER IF EXISTS `tg_b_ins_comandes`;$$
CREATE TRIGGER `tg_b_ins_comandes` BEFORE INSERT ON `comandes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'comandes', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_comandes`;$$
CREATE TRIGGER `tg_b_upd_comandes` BEFORE UPDATE ON `comandes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'comandes', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_comandes`;$$
CREATE TRIGGER `tg_b_del_comandes` BEFORE DELETE ON `comandes` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'comandes', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 9. cistell ===
DROP TRIGGER IF EXISTS `tg_b_ins_cistell`;$$
CREATE TRIGGER `tg_b_ins_cistell` BEFORE INSERT ON `cistell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cistell', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_cistell`;$$
CREATE TRIGGER `tg_b_upd_cistell` BEFORE UPDATE ON `cistell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cistell', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_cistell`;$$
CREATE TRIGGER `tg_b_del_cistell` BEFORE DELETE ON `cistell` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cistell', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 10. configuracio_qualitat ===
DROP TRIGGER IF EXISTS `tg_b_ins_configuracio_qualitat`;$$
CREATE TRIGGER `tg_b_ins_configuracio_qualitat` BEFORE INSERT ON `configuracio_qualitat` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'configuracio_qualitat', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_configuracio_qualitat`;$$
CREATE TRIGGER `tg_b_upd_configuracio_qualitat` BEFORE UPDATE ON `configuracio_qualitat` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'configuracio_qualitat', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_configuracio_qualitat`;$$
CREATE TRIGGER `tg_b_del_configuracio_qualitat` BEFORE DELETE ON `configuracio_qualitat` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'configuracio_qualitat', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 11. usuaris_sistema ===
DROP TRIGGER IF EXISTS `tg_b_ins_usuaris_sistema`;$$
CREATE TRIGGER `tg_b_ins_usuaris_sistema` BEFORE INSERT ON `usuaris_sistema` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'usuaris_sistema', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_usuaris_sistema`;$$
CREATE TRIGGER `tg_b_upd_usuaris_sistema` BEFORE UPDATE ON `usuaris_sistema` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'usuaris_sistema', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_usuaris_sistema`;$$
CREATE TRIGGER `tg_b_del_usuaris_sistema` BEFORE DELETE ON `usuaris_sistema` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'usuaris_sistema', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 12. servidors_videoconferencia ===
DROP TRIGGER IF EXISTS `tg_b_ins_servidors_videoconferencia`;$$
CREATE TRIGGER `tg_b_ins_servidors_videoconferencia` BEFORE INSERT ON `servidors_videoconferencia` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'servidors_videoconferencia', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_servidors_videoconferencia`;$$
CREATE TRIGGER `tg_b_upd_servidors_videoconferencia` BEFORE UPDATE ON `servidors_videoconferencia` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'servidors_videoconferencia', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_servidors_videoconferencia`;$$
CREATE TRIGGER `tg_b_del_servidors_videoconferencia` BEFORE DELETE ON `servidors_videoconferencia` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'servidors_videoconferencia', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 13. registre_trucades ===
DROP TRIGGER IF EXISTS `tg_b_ins_registre_trucades`;$$
CREATE TRIGGER `tg_b_ins_registre_trucades` BEFORE INSERT ON `registre_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'registre_trucades', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_registre_trucades`;$$
CREATE TRIGGER `tg_b_upd_registre_trucades` BEFORE UPDATE ON `registre_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'registre_trucades', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_registre_trucades`;$$
CREATE TRIGGER `tg_b_del_registre_trucades` BEFORE DELETE ON `registre_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'registre_trucades', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 14. cataleg_videos ===
DROP TRIGGER IF EXISTS `tg_b_ins_cataleg_videos`;$$
CREATE TRIGGER `tg_b_ins_cataleg_videos` BEFORE INSERT ON `cataleg_videos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cataleg_videos', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_cataleg_videos`;$$
CREATE TRIGGER `tg_b_upd_cataleg_videos` BEFORE UPDATE ON `cataleg_videos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cataleg_videos', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_cataleg_videos`;$$
CREATE TRIGGER `tg_b_del_cataleg_videos` BEFORE DELETE ON `cataleg_videos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'cataleg_videos', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 15. mesures_amplada_banda ===
DROP TRIGGER IF EXISTS `tg_b_ins_mesures_amplada_banda`;$$
CREATE TRIGGER `tg_b_ins_mesures_amplada_banda` BEFORE INSERT ON `mesures_amplada_banda` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'mesures_amplada_banda', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_mesures_amplada_banda`;$$
CREATE TRIGGER `tg_b_upd_mesures_amplada_banda` BEFORE UPDATE ON `mesures_amplada_banda` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'mesures_amplada_banda', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_mesures_amplada_banda`;$$
CREATE TRIGGER `tg_b_del_mesures_amplada_banda` BEFORE DELETE ON `mesures_amplada_banda` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'mesures_amplada_banda', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 16. taula_avisos (Sin auto-insert para evitar bucle recursivo) ===
DROP TRIGGER IF EXISTS `tg_b_ins_taula_avisos`;$$
CREATE TRIGGER `tg_b_ins_taula_avisos` BEFORE INSERT ON `taula_avisos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') AND v_role NOT IN ('vendes', 'administracio', 'treballador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Permisos insuficients.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_taula_avisos`;$$
CREATE TRIGGER `tg_b_upd_taula_avisos` BEFORE UPDATE ON `taula_avisos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Està prohibit modificar els registres d\'auditoria.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_taula_avisos`;$$
CREATE TRIGGER `tg_b_del_taula_avisos` BEFORE DELETE ON `taula_avisos` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Està prohibit esborrar els registres d\'auditoria.';
    END IF;
END;$$

-- === 17. quotes_trucades ===
DROP TRIGGER IF EXISTS `tg_b_ins_quotes_trucades`;$$
CREATE TRIGGER `tg_b_ins_quotes_trucades` BEFORE INSERT ON `quotes_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'quotes_trucades', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_quotes_trucades`;$$
CREATE TRIGGER `tg_b_upd_quotes_trucades` BEFORE UPDATE ON `quotes_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'quotes_trucades', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_quotes_trucades`;$$
CREATE TRIGGER `tg_b_del_quotes_trucades` BEFORE DELETE ON `quotes_trucades` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'quotes_trucades', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

-- === 18. control_backups ===
DROP TRIGGER IF EXISTS `tg_b_ins_control_backups`;$$
CREATE TRIGGER `tg_b_ins_control_backups` BEFORE INSERT ON `control_backups` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'control_backups', 'INSERT', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_upd_control_backups`;$$
CREATE TRIGGER `tg_b_upd_control_backups` BEFORE UPDATE ON `control_backups` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'control_backups', 'UPDATE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DROP TRIGGER IF EXISTS `tg_b_del_control_backups`;$$
CREATE TRIGGER `tg_b_del_control_backups` BEFORE DELETE ON `control_backups` FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50) DEFAULT SUBSTRING_INDEX(USER(), '@', 1);
    IF v_role IN ('vendes', 'administracio', 'treballador') THEN
        INSERT INTO `taula_avisos` (`usuari_mysql`, `taula_afectada`, `operacio_intentada`, `descripcio_error`)
        VALUES (USER(), 'control_backups', 'DELETE', CONCAT('Accés denegat: El rol \'', v_role, '\' no té permisos.'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguretat: Operació no permesa per al teu rol.';
    END IF;
END;$$

DELIMITER ;
