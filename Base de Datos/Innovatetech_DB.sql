-- ============================================================================
-- SCRIPT DE CREACIÓ DE LA BASE DE DADES I TAULES (InnovateTech)
-- Basat en l'estructura oficial de producció del servidor
-- ============================================================================

DROP DATABASE IF EXISTS innovate_tech_db;
CREATE DATABASE innovate_tech_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE innovate_tech_db;

-- ----------------------------------------------------------------------------
-- 1. TAULES MESTRES I D'ESTRUCTURA ORGANITZATIVA
-- ----------------------------------------------------------------------------

CREATE TABLE `rols_ldap` (
  `gid` int NOT NULL,
  `nom_rol` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`gid`),
  UNIQUE KEY `nom_rol` (`nom_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `departaments` (
  `id_departament` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nom` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefon` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_departament`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `grup_nivell` (
  `id_nivell` int NOT NULL AUTO_INCREMENT,
  `descripcio` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `salari_base` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_nivell`),
  CONSTRAINT `grup_nivell_chk_1` CHECK ((`salari_base` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `empleats` (
  `dni` varchar(9) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nom` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cognoms` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `adreça` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefon` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_departament` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_nivell` int NOT NULL,
  PRIMARY KEY (`dni`),
  KEY `fk_empleats_dept` (`id_departament`),
  KEY `fk_empleats_nivell` (`id_nivell`),
  CONSTRAINT `fk_empleats_dept` FOREIGN KEY (`id_departament`) REFERENCES `departaments` (`id_departament`),
  CONSTRAINT `fk_empleats_nivell` FOREIGN KEY (`id_nivell`) REFERENCES `grup_nivell` (`id_nivell`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `nominas` (
  `id_nomina` int NOT NULL AUTO_INCREMENT,
  `dni` varchar(9) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mes` int NOT NULL,
  `any` int NOT NULL,
  `import_total` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_nomina`),
  KEY `fk_nominas_empleat` (`dni`),
  CONSTRAINT `fk_nominas_empleat` FOREIGN KEY (`dni`) REFERENCES `empleats` (`dni`),
  CONSTRAINT `nominas_chk_1` CHECK ((`mes` between 1 and 12)),
  CONSTRAINT `nominas_chk_2` CHECK ((`any` >= 2020)),
  CONSTRAINT `nominas_chk_3` CHECK ((`import_total` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 2. TAULES DE NEGOCI I COMERÇ
-- ----------------------------------------------------------------------------

CREATE TABLE `clients` (
  `id_client` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cognoms` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `empresa` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correu_electronic` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefon` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `adreça` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_client`),
  UNIQUE KEY `correu_electronic` (`correu_electronic`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `productes` (
  `id_producte` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcio` text COLLATE utf8mb4_unicode_ci,
  `preu` decimal(10,2) NOT NULL,
  `stock` int NOT NULL,
  PRIMARY KEY (`id_producte`),
  CONSTRAINT `productes_chk_1` CHECK ((`preu` > 0)),
  CONSTRAINT `productes_chk_2` CHECK ((`stock` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `comandes` (
  `id_comanda` int NOT NULL AUTO_INCREMENT,
  `id_client` int NOT NULL,
  `data_comanda` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estat` enum('pendent','enviat','entregat','cancelat') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendent',
  PRIMARY KEY (`id_comanda`),
  KEY `fk_comandes_client` (`id_client`),
  CONSTRAINT `fk_comandes_client` FOREIGN KEY (`id_client`) REFERENCES `clients` (`id_client`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cistell` (
  `id_comanda` int NOT NULL,
  `id_producte` int NOT NULL,
  `quantitat` int NOT NULL,
  `preu_unitari` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_comanda`,`id_producte`),
  KEY `fk_cistell_producte` (`id_producte`),
  CONSTRAINT `fk_cistell_comanda` FOREIGN KEY (`id_comanda`) REFERENCES `comandes` (`id_comanda`) ON DELETE CASCADE,
  CONSTRAINT `fk_cistell_producte` FOREIGN KEY (`id_producte`) REFERENCES `productes` (`id_producte`),
  CONSTRAINT `cistell_chk_1` CHECK ((`quantitat` > 0)),
  CONSTRAINT `cistell_chk_2` CHECK ((`preu_unitari` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 3. TAULES DE COMUNICACIÓ (JITSI / ICECAST)
-- ----------------------------------------------------------------------------

CREATE TABLE `configuracio_qualitat` (
  `id_qualitat` int NOT NULL AUTO_INCREMENT,
  `nom_perfil` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resolucio` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bitrate_max` int NOT NULL,
  `limitacio_banda` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_qualitat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `usuaris_sistema` (
  `id_usuari` int NOT NULL AUTO_INCREMENT,
  `nom_complet` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correu_electronic` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `extensio_trucades` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estat` enum('actiu','bloquejat') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'actiu',
  `tipus_usuari` enum('intern','extern') COLLATE utf8mb4_unicode_ci NOT NULL,
  `gid_rol` int NOT NULL,
  `id_qualitat` int NOT NULL,
  `dni_empleat` varchar(9) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url_videotrucada` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_usuari`),
  UNIQUE KEY `correu_electronic` (`correu_electronic`),
  UNIQUE KEY `extensio_trucades` (`extensio_trucades`),
  KEY `fk_usuaris_rol` (`gid_rol`),
  KEY `fk_usuaris_qualitat` (`id_qualitat`),
  KEY `fk_usuaris_empleat` (`dni_empleat`),
  CONSTRAINT `fk_usuaris_empleat` FOREIGN KEY (`dni_empleat`) REFERENCES `empleats` (`dni`) ON DELETE SET NULL,
  CONSTRAINT `fk_usuaris_qualitat` FOREIGN KEY (`id_qualitat`) REFERENCES `configuracio_qualitat` (`id_qualitat`),
  CONSTRAINT `fk_usuaris_rol` FOREIGN KEY (`gid_rol`) REFERENCES `rols_ldap` (`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `servidors_videoconferencia` (
  `id_servidor` int NOT NULL AUTO_INCREMENT,
  `ip_publica` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_privada` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `port` int NOT NULL,
  `protocol` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_servidor`),
  CONSTRAINT `servidors_videoconferencia_chk_1` CHECK ((`port` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `registre_trucades` (
  `id_trucada` int NOT NULL AUTO_INCREMENT,
  `id_usuari_origen` int NOT NULL,
  `id_usuari_desti` int NOT NULL,
  `data_hora_inici` datetime NOT NULL,
  `data_hora_fi` datetime NOT NULL,
  `durada_segons` int NOT NULL,
  `id_qualitat_usada` int NOT NULL,
  `puntuacio_servei` int DEFAULT NULL,
  `comentari_servei` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id_trucada`),
  KEY `fk_trucades_origen` (`id_usuari_origen`),
  KEY `fk_trucades_desti` (`id_usuari_desti`),
  KEY `fk_trucades_qualitat` (`id_qualitat_usada`),
  CONSTRAINT `fk_trucades_desti` FOREIGN KEY (`id_usuari_desti`) REFERENCES `usuaris_sistema` (`id_usuari`),
  CONSTRAINT `fk_trucades_origen` FOREIGN KEY (`id_usuari_origen`) REFERENCES `usuaris_sistema` (`id_usuari`),
  CONSTRAINT `fk_trucades_qualitat` FOREIGN KEY (`id_qualitat_usada`) REFERENCES `configuracio_qualitat` (`id_qualitat`),
  CONSTRAINT `chk_dates_trucada` CHECK ((`data_hora_fi` >= `data_hora_inici`)),
  CONSTRAINT `registre_trucades_chk_1` CHECK ((`durada_segons` >= 0)),
  CONSTRAINT `registre_trucades_chk_2` CHECK ((`puntuacio_servei` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cataleg_videos` (
  `id_video` int NOT NULL AUTO_INCREMENT,
  `titol` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcio` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `categoria` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `durada_segons` int NOT NULL,
  `data_publicacio` date NOT NULL,
  `enllaç_streaming` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_video`),
  CONSTRAINT `cataleg_videos_chk_1` CHECK ((`durada_segons` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 4. SEGURETAT, MANTENIMENT I MONITORATGE
-- ----------------------------------------------------------------------------

CREATE TABLE `mesures_amplada_banda` (
  `id_mesura` int NOT NULL AUTO_INCREMENT,
  `data_hora` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_usuari_mesurat` int NOT NULL,
  `velocitat_baixada_mbps` decimal(6,2) NOT NULL,
  `velocitat_pujada_mbps` decimal(6,2) NOT NULL,
  `latencia_ms` int NOT NULL,
  `resultat` enum('acceptable','no acceptable') COLLATE utf8mb4_unicode_ci NOT NULL,
  `dni_operari` varchar(9) COLLATE utf8mb4_unicode_ci NOT NULL,
  `observacions` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id_mesura`),
  KEY `fk_mesures_usuari` (`id_usuari_mesurat`),
  KEY `fk_mesures_operari` (`dni_operari`),
  CONSTRAINT `fk_mesures_operari` FOREIGN KEY (`dni_operari`) REFERENCES `empleats` (`dni`),
  CONSTRAINT `fk_mesures_usuari` FOREIGN KEY (`id_usuari_mesurat`) REFERENCES `usuaris_sistema` (`id_usuari`),
  CONSTRAINT `mesures_amplada_banda_chk_1` CHECK ((`velocitat_baixada_mbps` >= 0)),
  CONSTRAINT `mesures_amplada_banda_chk_2` CHECK ((`velocitat_pujada_mbps` >= 0)),
  CONSTRAINT `mesures_amplada_banda_chk_3` CHECK ((`latencia_ms` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `taula_avisos` (
  `id_avis` int NOT NULL AUTO_INCREMENT,
  `usuari_mysql` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `taula_afectada` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `operacio_intentada` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_hora` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `descripcio_error` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_avis`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `quotes_trucades` (
  `id_quota` int NOT NULL AUTO_INCREMENT,
  `id_usuari` int NOT NULL,
  `minuts_mensuals_max` int NOT NULL DEFAULT '600',
  `trucades_diaries_max` int NOT NULL DEFAULT '50',
  `minuts_consumits_mes` int NOT NULL DEFAULT '0',
  `trucades_consumides_avui` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_quota`),
  UNIQUE KEY `id_usuari` (`id_usuari`),
  CONSTRAINT `fk_quotes_usuari` FOREIGN KEY (`id_usuari`) REFERENCES `usuaris_sistema` (`id_usuari`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `control_backups` (
  `id_backup` int NOT NULL AUTO_INCREMENT,
  `data_hora` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `taules_incloses` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resultat` enum('correcte','error') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_backup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 5. INSERCIÓ DE VALORS MESTRES OBLIGATORIS
-- ----------------------------------------------------------------------------

INSERT INTO `rols_ldap` (`gid`, `nom_rol`) VALUES 
(3001, 'admin'),
(3002, 'vendes'),
(3003, 'administracio'),
(3004, 'treballador');

INSERT INTO `configuracio_qualitat` (`nom_perfil`, `resolucio`, `bitrate_max`, `limitacio_banda`) VALUES
('alta', '1080p', 4000, 0),
('mitja', '720p', 2000, 0),
('baixa', '480p', 800, 1);
