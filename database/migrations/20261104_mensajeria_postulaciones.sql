USE portal_empleo_inclusivo;

ALTER TABLE notificaciones MODIFY tipo ENUM(
    'POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE','CONADIS_ESTADO',
    'CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL','CLAVE_CAMBIADA','ACTIVIDAD_SOSPECHOSA',
    'MENSAJE_SOPORTE','NUEVO_MENSAJE'
) NOT NULL;

-- Conversaciones privadas entre la empresa propietaria de la oferta y el postulante.
CREATE TABLE IF NOT EXISTS mensajes_postulacion (
    id_mensaje BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_postulacion INT NOT NULL,
    id_remitente INT NOT NULL,
    mensaje VARCHAR(2000) NOT NULL,
    leido TINYINT(1) NOT NULL DEFAULT 0,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mensaje_postulacion FOREIGN KEY(id_postulacion) REFERENCES postulaciones(id_postulacion) ON DELETE CASCADE,
    CONSTRAINT fk_mensaje_remitente FOREIGN KEY(id_remitente) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX idx_mensaje_hilo(id_postulacion,id_mensaje),
    INDEX idx_mensaje_no_leido(id_postulacion,leido,id_remitente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
