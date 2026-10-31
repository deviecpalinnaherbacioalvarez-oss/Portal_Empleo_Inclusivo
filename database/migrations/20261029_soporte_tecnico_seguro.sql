-- Parte 5: Soporte Tecnico seguro, claves temporales y auditoria.
USE portal_empleo_inclusivo;

SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='clave_temporal_expira')=0,
 'ALTER TABLE usuarios ADD COLUMN clave_temporal_expira DATETIME NULL', 'SELECT 1');
PREPARE soporte_stmt FROM @ddl; EXECUTE soporte_stmt; DEALLOCATE PREPARE soporte_stmt;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='motivo_bloqueo')=0,
 'ALTER TABLE usuarios ADD COLUMN motivo_bloqueo VARCHAR(500) NOT NULL DEFAULT ''''', 'SELECT 1');
PREPARE soporte_stmt FROM @ddl; EXECUTE soporte_stmt; DEALLOCATE PREPARE soporte_stmt;

SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='numero_ticket')=0,
 'ALTER TABLE incidencias_soporte ADD COLUMN numero_ticket VARCHAR(30) NULL', 'SELECT 1');
PREPARE soporte_stmt FROM @ddl; EXECUTE soporte_stmt; DEALLOCATE PREPARE soporte_stmt;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='identidad_verificada')=0, 'ALTER TABLE incidencias_soporte ADD COLUMN identidad_verificada TINYINT(1) NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE soporte_stmt FROM @ddl; EXECUTE soporte_stmt; DEALLOCATE PREPARE soporte_stmt;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='metodo_verificacion')=0, 'ALTER TABLE incidencias_soporte ADD COLUMN metodo_verificacion VARCHAR(80) NOT NULL DEFAULT ''''', 'SELECT 1');
PREPARE soporte_stmt FROM @ddl; EXECUTE soporte_stmt; DEALLOCATE PREPARE soporte_stmt;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='motivo_accion')=0, 'ALTER TABLE incidencias_soporte ADD COLUMN motivo_accion VARCHAR(1000) NOT NULL DEFAULT ''''', 'SELECT 1');
PREPARE soporte_stmt FROM @ddl; EXECUTE soporte_stmt; DEALLOCATE PREPARE soporte_stmt;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='fecha_verificacion')=0, 'ALTER TABLE incidencias_soporte ADD COLUMN fecha_verificacion DATETIME NULL', 'SELECT 1');
PREPARE soporte_stmt FROM @ddl; EXECUTE soporte_stmt; DEALLOCATE PREPARE soporte_stmt;

UPDATE incidencias_soporte SET numero_ticket=CONCAT('INC-',LPAD(id_incidencia,8,'0')) WHERE numero_ticket IS NULL OR numero_ticket='';
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND index_name='uq_incidencia_ticket')=0,
 'ALTER TABLE incidencias_soporte MODIFY numero_ticket VARCHAR(30) NOT NULL, ADD UNIQUE KEY uq_incidencia_ticket(numero_ticket)', 'SELECT 1');
PREPARE soporte_stmt FROM @ddl; EXECUTE soporte_stmt; DEALLOCATE PREPARE soporte_stmt;

ALTER TABLE notificaciones MODIFY tipo ENUM(
 'POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE','CONADIS_ESTADO',
 'CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL','CLAVE_CAMBIADA','ACTIVIDAD_SOSPECHOSA','MENSAJE_SOPORTE'
) NOT NULL;

CREATE TABLE IF NOT EXISTS auditoria_soporte (
 id_auditoria BIGINT AUTO_INCREMENT PRIMARY KEY,
 id_incidencia INT NOT NULL,
 id_usuario_afectado INT NOT NULL,
 id_responsable INT NOT NULL,
 accion ENUM('IDENTIDAD_VERIFICADA','IDENTIDAD_RECHAZADA','CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL_GENERADA','NOTIFICACION_ENVIADA') NOT NULL,
 motivo VARCHAR(1000) NOT NULL,
 resultado ENUM('EXITO','RECHAZADO','ERROR') NOT NULL,
 metodo_verificacion VARCHAR(80) NOT NULL DEFAULT '',
 fecha_accion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_auditoria_soporte_incidencia FOREIGN KEY(id_incidencia) REFERENCES incidencias_soporte(id_incidencia),
 CONSTRAINT fk_auditoria_soporte_afectado FOREIGN KEY(id_usuario_afectado) REFERENCES usuarios(id_usuario),
 CONSTRAINT fk_auditoria_soporte_responsable FOREIGN KEY(id_responsable) REFERENCES usuarios(id_usuario),
 INDEX idx_auditoria_soporte_responsable_fecha(id_responsable,fecha_accion),
 INDEX idx_auditoria_soporte_afectado_fecha(id_usuario_afectado,fecha_accion)
);
