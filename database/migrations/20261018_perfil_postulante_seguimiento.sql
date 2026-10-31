-- Perfil profesional y seguimiento de postulaciones. Migracion repetible.
USE portal_empleo_inclusivo;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='perfiles_postulantes' AND column_name='titular')=0,
 'ALTER TABLE perfiles_postulantes ADD COLUMN titular VARCHAR(160) NOT NULL DEFAULT '''', ADD COLUMN ubicacion VARCHAR(120) NOT NULL DEFAULT '''', ADD COLUMN acerca_de TEXT NULL, ADD COLUMN foto_url VARCHAR(255) NOT NULL DEFAULT '''', ADD COLUMN cv_nombre VARCHAR(255) NOT NULL DEFAULT '''', ADD COLUMN cv_archivo VARCHAR(255) NOT NULL DEFAULT '''', ADD COLUMN cv_actualizado DATETIME NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='perfiles_postulantes' AND index_name='uq_perfil_usuario')=0,
 'ALTER TABLE perfiles_postulantes ADD UNIQUE KEY uq_perfil_usuario(id_usuario)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS experiencias_postulante (
 id_experiencia INT AUTO_INCREMENT PRIMARY KEY, id_usuario INT NOT NULL,
 cargo VARCHAR(150) NOT NULL, organizacion VARCHAR(150) NOT NULL,
 fecha_inicio VARCHAR(30) NOT NULL, fecha_fin VARCHAR(30) NOT NULL,
 descripcion VARCHAR(2000) NOT NULL DEFAULT '',
 FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS educacion_postulante (
 id_educacion INT AUTO_INCREMENT PRIMARY KEY, id_usuario INT NOT NULL,
 institucion VARCHAR(180) NOT NULL, carrera VARCHAR(180) NOT NULL,
 fecha_inicio VARCHAR(30) NOT NULL, fecha_fin VARCHAR(30) NOT NULL,
 descripcion VARCHAR(2000) NOT NULL DEFAULT '',
 FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS certificaciones_postulante (
 id_certificacion INT AUTO_INCREMENT PRIMARY KEY, id_usuario INT NOT NULL,
 nombre VARCHAR(200) NOT NULL, emisor VARCHAR(150) NOT NULL,
 fecha_emision VARCHAR(30) NOT NULL, credencial_url VARCHAR(500) NOT NULL DEFAULT '',
 FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);
