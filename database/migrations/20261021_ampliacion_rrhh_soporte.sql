-- Ampliacion de Recursos Humanos y Soporte Tecnico (2026-10-21).
USE portal_empleo_inclusivo;

ALTER TABLE evaluaciones_rrhh
    MODIFY resultado ENUM('PENDIENTE','APROBADO','NO_APROBADO') NOT NULL DEFAULT 'PENDIENTE';

SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='evaluaciones_rrhh' AND column_name='puntaje_cv');
SET @ddl=IF(@missing,'ALTER TABLE evaluaciones_rrhh ADD COLUMN puntaje_cv TINYINT UNSIGNED NOT NULL DEFAULT 0','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='evaluaciones_rrhh' AND column_name='puntaje_entrevista');
SET @ddl=IF(@missing,'ALTER TABLE evaluaciones_rrhh ADD COLUMN puntaje_entrevista TINYINT UNSIGNED NOT NULL DEFAULT 0','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='evaluaciones_rrhh' AND column_name='puntaje_desempeno');
SET @ddl=IF(@missing,'ALTER TABLE evaluaciones_rrhh ADD COLUMN puntaje_desempeno TINYINT UNSIGNED NOT NULL DEFAULT 0','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='evaluaciones_rrhh' AND column_name='porcentaje_compatibilidad');
SET @ddl=IF(@missing,'ALTER TABLE evaluaciones_rrhh ADD COLUMN porcentaje_compatibilidad TINYINT UNSIGNED NOT NULL DEFAULT 0','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='evaluaciones_rrhh' AND column_name='etapa');
SET @ddl=IF(@missing,'ALTER TABLE evaluaciones_rrhh ADD COLUMN etapa ENUM(''REVISION_CV'',''ENTREVISTA'',''DESEMPENO'',''FINAL'') NOT NULL DEFAULT ''REVISION_CV''','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='evaluaciones_rrhh' AND column_name='retroalimentacion');
SET @ddl=IF(@missing,'ALTER TABLE evaluaciones_rrhh ADD COLUMN retroalimentacion VARCHAR(4000) NOT NULL DEFAULT ''''','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;

SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='requiere_cambio_clave');
SET @ddl=IF(@missing,'ALTER TABLE usuarios ADD COLUMN requiere_cambio_clave TINYINT(1) NOT NULL DEFAULT 0','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;

SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='categoria');
SET @ddl=IF(@missing,'ALTER TABLE incidencias_soporte ADD COLUMN categoria ENUM(''SEGURIDAD'',''ACCESO'',''INFRACCION'',''TECNICO'',''OTRO'') NOT NULL DEFAULT ''TECNICO'' AFTER origen','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='id_usuario_afectado');
SET @ddl=IF(@missing,'ALTER TABLE incidencias_soporte ADD COLUMN id_usuario_afectado INT NULL AFTER id_responsable','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;
SET @fk_missing=(SELECT COUNT(*)=0 FROM information_schema.table_constraints WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND constraint_name='fk_incidencia_usuario_afectado');
SET @ddl=IF(@fk_missing,'ALTER TABLE incidencias_soporte ADD CONSTRAINT fk_incidencia_usuario_afectado FOREIGN KEY(id_usuario_afectado) REFERENCES usuarios(id_usuario) ON DELETE SET NULL','SELECT 1');
PREPARE x FROM @ddl; EXECUTE x; DEALLOCATE PREPARE x;

UPDATE incidencias_soporte i
JOIN usuarios u ON LOWER(u.correo)=LOWER(i.correo)
SET i.id_usuario_afectado=u.id_usuario
WHERE i.id_usuario_afectado IS NULL;


