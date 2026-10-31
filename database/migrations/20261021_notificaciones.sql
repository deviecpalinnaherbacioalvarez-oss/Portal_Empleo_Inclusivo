-- Notificaciones internas para postulantes y Soporte Tecnico.
USE portal_empleo_inclusivo;

CREATE TABLE IF NOT EXISTS notificaciones (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo ENUM('POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE') NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    mensaje VARCHAR(1000) NOT NULL,
    leida TINYINT(1) NOT NULL DEFAULT 0,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notificacion_usuario FOREIGN KEY(id_usuario)
        REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX idx_notificacion_usuario_fecha(id_usuario,fecha_creacion)
);
