-- Cambio incremental sobre la base actual. No elimina registros ni activa la migración de 17 tablas.
ALTER TABLE usuarios MODIFY nombre VARCHAR(170) NOT NULL;
ALTER TABLE verificaciones_conadis
 MODIFY rui VARCHAR(10) NULL, MODIFY dni CHAR(8) NULL,
 MODIFY apellidos VARCHAR(80) NULL, MODIFY nombres VARCHAR(80) NULL,
 MODIFY fecha_caducidad DATE NULL,
 ADD COLUMN id_discapacidad TINYINT UNSIGNED NULL,
 ADD COLUMN revision_rrhh BOOLEAN NOT NULL DEFAULT FALSE,
 ADD CONSTRAINT fk_verificacion_discapacidad_rrhh FOREIGN KEY(id_discapacidad) REFERENCES discapacidades(id_discapacidad),
 ADD CONSTRAINT uq_verificacion_rrhh_rui UNIQUE(rui),
 ADD CONSTRAINT uq_verificacion_rrhh_dni UNIQUE(dni);
ALTER TABLE perfiles_postulantes
 ADD COLUMN id_discapacidad TINYINT UNSIGNED NULL,
 ADD CONSTRAINT fk_perfil_discapacidad_rrhh FOREIGN KEY(id_discapacidad) REFERENCES discapacidades(id_discapacidad);
DELIMITER $$
CREATE TRIGGER bi_conadis_foto_rrhh BEFORE INSERT ON verificaciones_conadis FOR EACH ROW
BEGIN
 IF NEW.revision_rrhh<>1 OR NEW.estado<>'PENDIENTE' OR NEW.id_revisor IS NOT NULL
 OR NEW.rui IS NOT NULL OR NEW.dni IS NOT NULL OR NEW.nombres IS NOT NULL OR NEW.apellidos IS NOT NULL
 OR NEW.fecha_caducidad IS NOT NULL OR NEW.id_discapacidad IS NOT NULL
 OR NEW.carnet_archivo IS NULL OR TRIM(NEW.carnet_archivo)='' THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La solicitud solo contiene la imagen y queda pendiente de RRHH.';
 END IF;
END$$
CREATE TRIGGER bu_conadis_datos_rrhh BEFORE UPDATE ON verificaciones_conadis FOR EACH ROW
BEGIN
 IF NEW.id_usuario<>OLD.id_usuario OR NEW.id_verificacion<>OLD.id_verificacion THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se puede cambiar el titular de la solicitud.';
 END IF;
 IF OLD.revision_rrhh=1 AND OLD.estado='APROBADA' THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Los datos aprobados por RRHH no son editables.';
 END IF;
 IF NEW.revision_rrhh=1 AND NEW.estado='APROBADA' THEN
 IF NEW.id_revisor IS NULL OR NOT EXISTS(SELECT 1 FROM usuarios WHERE id_usuario=NEW.id_revisor AND rol='RECURSOS_HUMANOS' AND estado='activo')
 OR NEW.metodo IS NULL OR NEW.metodo<>'MANUAL'
 OR NEW.rui IS NULL OR NEW.dni IS NULL OR NEW.nombres IS NULL OR NEW.apellidos IS NULL
 OR NEW.fecha_caducidad IS NULL OR NEW.fecha_caducidad<CURDATE()
 OR NEW.id_discapacidad IS NULL OR NEW.fecha_revision IS NULL
 OR TRIM(NEW.carnet_archivo)='' THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La aprobación exige datos completos y un revisor RRHH activo.';
 END IF;
 END IF;
END$$
CREATE TRIGGER bu_perfil_verificado_rrhh BEFORE UPDATE ON perfiles_postulantes FOR EACH ROW
BEGIN
 IF EXISTS(SELECT 1 FROM verificaciones_conadis WHERE id_usuario=OLD.id_usuario AND revision_rrhh=1 AND estado='APROBADA')
 AND (NOT(NEW.dni<=>OLD.dni) OR NOT(NEW.tipo_discapacidad<=>OLD.tipo_discapacidad)
 OR NOT(NEW.id_discapacidad<=>OLD.id_discapacidad) OR NEW.id_usuario<>OLD.id_usuario) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Los datos del carnet verificado por RRHH están bloqueados.';
 END IF;
END$$
CREATE TRIGGER bu_nombre_verificado_rrhh BEFORE UPDATE ON usuarios FOR EACH ROW
BEGIN
 IF NOT(NEW.nombre<=>OLD.nombre) AND EXISTS(SELECT 1 FROM verificaciones_conadis WHERE id_usuario=OLD.id_usuario AND revision_rrhh=1 AND estado='APROBADA') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El nombre verificado por RRHH no puede cambiarse desde el perfil.';
 END IF;
END$$
CREATE TRIGGER bd_conadis_verificado_rrhh BEFORE DELETE ON verificaciones_conadis FOR EACH ROW
BEGIN
 IF OLD.revision_rrhh=1 AND OLD.estado='APROBADA' THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se puede borrar la aprobación para desbloquear los datos.';
 END IF;
END$$
DELIMITER ;
