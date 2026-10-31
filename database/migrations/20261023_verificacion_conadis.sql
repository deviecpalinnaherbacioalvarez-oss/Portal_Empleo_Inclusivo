-- Estructura inicial de solicitudes CONADIS. La resolución es manual por RRHH.
-- No crea padrones ficticios ni aprobaciones automáticas.
USE portal_empleo_inclusivo;

CREATE TABLE IF NOT EXISTS verificaciones_conadis (
    id_verificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    rui VARCHAR(20) NOT NULL,
    dni CHAR(8) NULL,
    apellidos VARCHAR(80) NULL,
    nombres VARCHAR(80) NULL,
    fecha_caducidad DATE NULL,
    carnet_archivo VARCHAR(255) NOT NULL,
    estado ENUM('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') NOT NULL DEFAULT 'PENDIENTE',
    metodo ENUM('MANUAL') NULL,
    observacion_sistema VARCHAR(1000) NOT NULL DEFAULT '',
    motivo VARCHAR(1000) NOT NULL DEFAULT '',
    id_revisor INT NULL,
    revision_rrhh BOOLEAN NOT NULL DEFAULT TRUE,
    envios SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    fecha_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_revision DATETIME NULL,
    UNIQUE KEY uq_verificacion_usuario(id_usuario),
    UNIQUE KEY uq_verificacion_rui(rui),
    INDEX idx_verificacion_estado(estado,fecha_envio),
    INDEX idx_verificacion_dni(dni),
    CONSTRAINT fk_verificacion_usuario FOREIGN KEY(id_usuario)
        REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_verificacion_revisor FOREIGN KEY(id_revisor)
        REFERENCES usuarios(id_usuario) ON DELETE SET NULL
);
