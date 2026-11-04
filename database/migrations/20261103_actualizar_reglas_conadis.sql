USE portal_empleo_inclusivo;

-- Alinea una base antigua con las reglas actuales sin modificar solicitudes.
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='consentimiento_datos_at')=0,'ALTER TABLE verificaciones_conadis ADD COLUMN consentimiento_datos_at DATETIME NULL','SELECT 1');
PREPARE conadis_stmt FROM @ddl; EXECUTE conadis_stmt; DEALLOCATE PREPARE conadis_stmt;

CREATE TABLE IF NOT EXISTS historial_verificaciones_conadis (
 id_historial BIGINT AUTO_INCREMENT PRIMARY KEY,id_verificacion INT NOT NULL,id_usuario INT NOT NULL,
 rui VARCHAR(20) NOT NULL,carnet_archivo VARCHAR(255) NOT NULL,
 estado ENUM('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') NOT NULL,motivo VARCHAR(1000) NOT NULL DEFAULT '',
 id_revisor INT NULL,accion VARCHAR(40) NOT NULL,fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_historial_verificacion_fecha(id_verificacion,fecha_evento),INDEX idx_historial_usuario_fecha(id_usuario,fecha_evento),
 FOREIGN KEY(id_verificacion) REFERENCES verificaciones_conadis(id_verificacion) ON DELETE RESTRICT,
 FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,
 FOREIGN KEY(id_revisor) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS esquema_version (version VARCHAR(20) PRIMARY KEY,fecha_aplicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP);

DROP TRIGGER IF EXISTS bi_conadis_foto_rrhh;
DROP TRIGGER IF EXISTS bu_conadis_datos_rrhh;
DROP TRIGGER IF EXISTS bd_conadis_verificado_rrhh;
DROP TRIGGER IF EXISTS bi_conadis_obligatoria;
DROP TRIGGER IF EXISTS bu_conadis_obligatoria;
DROP TRIGGER IF EXISTS bd_conadis_auditada;
DELIMITER $$
CREATE TRIGGER bi_conadis_obligatoria BEFORE INSERT ON verificaciones_conadis FOR EACH ROW
BEGIN
 IF NEW.estado<>'PENDIENTE' OR NEW.id_revisor IS NOT NULL OR NEW.rui IS NULL OR TRIM(NEW.rui)='' OR NEW.carnet_archivo IS NULL OR TRIM(NEW.carnet_archivo)='' OR NEW.consentimiento_datos_at IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La solicitud inicial requiere consentimiento, RUI, fotografia y estado PENDIENTE.'; END IF;
END$$
CREATE TRIGGER bu_conadis_obligatoria BEFORE UPDATE ON verificaciones_conadis FOR EACH ROW
BEGIN
 IF NEW.id_usuario<>OLD.id_usuario OR NEW.id_verificacion<>OLD.id_verificacion THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se puede cambiar el titular de la solicitud.'; END IF;
 IF NEW.estado NOT IN ('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') OR NEW.rui IS NULL OR TRIM(NEW.rui)='' OR NEW.carnet_archivo IS NULL OR TRIM(NEW.carnet_archivo)='' OR NEW.consentimiento_datos_at IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La verificacion requiere consentimiento, RUI, fotografia y estado validos.'; END IF;
 IF NEW.estado IN ('APROBADA','RECHAZADA','VENCIDA') AND (NEW.id_revisor IS NULL OR NOT EXISTS(SELECT 1 FROM usuarios u WHERE u.id_usuario=NEW.id_revisor AND u.rol='RECURSOS_HUMANOS' AND u.estado='activo')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La resolucion requiere un revisor de Recursos Humanos activo.'; END IF;
 IF NEW.estado='APROBADA' AND (NEW.metodo IS NULL OR NEW.metodo<>'MANUAL' OR NEW.dni IS NULL OR NEW.nombres IS NULL OR NEW.apellidos IS NULL OR NEW.fecha_caducidad IS NULL OR NEW.fecha_caducidad<CURDATE() OR NEW.consentimiento_datos_at IS NULL OR NEW.fecha_revision IS NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La aprobacion manual requiere datos completos y vigentes.'; END IF;
END$$
CREATE TRIGGER bd_conadis_auditada BEFORE DELETE ON verificaciones_conadis FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las solicitudes CONADIS auditadas no se eliminan.';
END$$
DELIMITER ;

INSERT INTO esquema_version(version) VALUES ('2026.11.03-conadis') ON DUPLICATE KEY UPDATE fecha_aplicacion=CURRENT_TIMESTAMP;
