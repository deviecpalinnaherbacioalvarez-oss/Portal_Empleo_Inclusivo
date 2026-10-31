-- Parte 3: verificacion CONADIS obligatoria y auditada para POSTULANTES.
USE portal_empleo_inclusivo;

-- El proyecto no usa un padron ficticio como fuente de validacion oficial.
DROP TABLE IF EXISTS padron_conadis;

DROP TRIGGER IF EXISTS bi_conadis_foto_rrhh;
DROP TRIGGER IF EXISTS bu_conadis_datos_rrhh;
DROP TRIGGER IF EXISTS bd_conadis_verificado_rrhh;
DROP TRIGGER IF EXISTS bi_conadis_obligatoria;
DROP TRIGGER IF EXISTS bu_conadis_obligatoria;
DROP TRIGGER IF EXISTS bd_conadis_auditada;

UPDATE verificaciones_conadis
SET estado='RECHAZADA',metodo=NULL,
    motivo='Registro legado sin revisión manual. Vuelve a enviar el RUI y la fotografía.',
    observacion_sistema='Requiere una nueva revisión manual por Recursos Humanos.',
    id_revisor=NULL,fecha_revision=NULL
WHERE metodo='AUTOMATICA';

UPDATE verificaciones_conadis
SET estado='RECHAZADA',metodo=NULL,
    motivo='Solicitud antigua incompleta. Vuelve a enviar el RUI y la fotografía.',
    observacion_sistema='Requiere un nuevo envío completo y revisión manual por Recursos Humanos.',
    id_revisor=NULL,fecha_revision=NULL
WHERE rui IS NULL OR TRIM(rui)='' OR carnet_archivo IS NULL OR TRIM(carnet_archivo)='';

ALTER TABLE verificaciones_conadis
    MODIFY rui VARCHAR(20) NULL,
    MODIFY estado ENUM('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') NOT NULL DEFAULT 'PENDIENTE',
    MODIFY metodo ENUM('MANUAL') NULL;

SET @tiene_uq_rui=(SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis'
      AND index_name IN ('uq_verificacion_rrhh_rui','uq_verificacion_rui') AND non_unique=0);
SET @sql_uq_rui=IF(@tiene_uq_rui=0,
    'ALTER TABLE verificaciones_conadis ADD CONSTRAINT uq_verificacion_rui UNIQUE(rui)',
    'SELECT 1');
PREPARE stmt_uq_rui FROM @sql_uq_rui;
EXECUTE stmt_uq_rui;
DEALLOCATE PREPARE stmt_uq_rui;

ALTER TABLE notificaciones
    MODIFY tipo ENUM('POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE','CONADIS_ESTADO') NOT NULL;

CREATE TABLE IF NOT EXISTS historial_verificaciones_conadis (
    id_historial BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_verificacion INT NOT NULL,
    id_usuario INT NOT NULL,
    rui VARCHAR(20) NOT NULL,
    carnet_archivo VARCHAR(255) NOT NULL,
    estado ENUM('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') NOT NULL,
    motivo VARCHAR(1000) NOT NULL DEFAULT '',
    id_revisor INT NULL,
    accion VARCHAR(40) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_historial_verificacion_fecha(id_verificacion,fecha_evento),
    INDEX idx_historial_usuario_fecha(id_usuario,fecha_evento),
    CONSTRAINT fk_historial_verificacion FOREIGN KEY(id_verificacion)
        REFERENCES verificaciones_conadis(id_verificacion) ON DELETE RESTRICT,
    CONSTRAINT fk_historial_usuario FOREIGN KEY(id_usuario)
        REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,
    CONSTRAINT fk_historial_revisor FOREIGN KEY(id_revisor)
        REFERENCES usuarios(id_usuario) ON DELETE SET NULL
);

INSERT INTO historial_verificaciones_conadis
    (id_verificacion,id_usuario,rui,carnet_archivo,estado,motivo,id_revisor,accion,fecha_evento)
SELECT v.id_verificacion,v.id_usuario,v.rui,v.carnet_archivo,
       CASE WHEN v.estado='APROBADA' AND v.fecha_caducidad<CURDATE() THEN 'VENCIDA' ELSE v.estado END,
       v.motivo,v.id_revisor,'MIGRACION_INICIAL',COALESCE(v.fecha_revision,v.fecha_envio,NOW())
FROM verificaciones_conadis v
WHERE v.rui IS NOT NULL AND TRIM(v.rui)<>'' AND v.carnet_archivo IS NOT NULL AND TRIM(v.carnet_archivo)<>''
  AND NOT EXISTS(SELECT 1 FROM historial_verificaciones_conadis h WHERE h.id_verificacion=v.id_verificacion);

UPDATE verificaciones_conadis
SET estado='VENCIDA',observacion_sistema='La vigencia registrada terminó; se requiere un nuevo envío.'
WHERE estado='APROBADA' AND fecha_caducidad<CURDATE();

DELIMITER $$
CREATE TRIGGER bi_conadis_obligatoria BEFORE INSERT ON verificaciones_conadis FOR EACH ROW
BEGIN
    IF NEW.estado<>'PENDIENTE' OR NEW.id_revisor IS NOT NULL
       OR NEW.rui IS NULL OR TRIM(NEW.rui)=''
       OR NEW.carnet_archivo IS NULL OR TRIM(NEW.carnet_archivo)='' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La solicitud inicial requiere RUI, fotografia y estado PENDIENTE.';
    END IF;
END$$

CREATE TRIGGER bu_conadis_obligatoria BEFORE UPDATE ON verificaciones_conadis FOR EACH ROW
BEGIN
    IF NEW.id_usuario<>OLD.id_usuario OR NEW.id_verificacion<>OLD.id_verificacion THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se puede cambiar el titular de la solicitud.';
    END IF;
    IF NEW.estado NOT IN ('PENDIENTE','APROBADA','RECHAZADA','VENCIDA')
       OR NEW.rui IS NULL OR TRIM(NEW.rui)=''
       OR NEW.carnet_archivo IS NULL OR TRIM(NEW.carnet_archivo)='' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La verificacion requiere estado, RUI y fotografia validos.';
    END IF;
    IF NEW.estado IN ('APROBADA','RECHAZADA','VENCIDA')
       AND (NEW.id_revisor IS NULL OR NOT EXISTS(
           SELECT 1 FROM usuarios u WHERE u.id_usuario=NEW.id_revisor
             AND u.rol='RECURSOS_HUMANOS' AND u.estado='activo')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La resolucion requiere un revisor de Recursos Humanos activo.';
    END IF;
    IF NEW.estado='APROBADA' AND (NEW.metodo IS NULL OR NEW.metodo<>'MANUAL' OR NEW.dni IS NULL
       OR NEW.nombres IS NULL OR NEW.apellidos IS NULL OR NEW.fecha_caducidad IS NULL
       OR NEW.fecha_caducidad<CURDATE() OR NEW.id_discapacidad IS NULL OR NEW.fecha_revision IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La aprobacion manual requiere datos completos y vigentes.';
    END IF;
END$$

CREATE TRIGGER bd_conadis_auditada BEFORE DELETE ON verificaciones_conadis FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las solicitudes CONADIS auditadas no se eliminan.';
END$$
DELIMITER ;
