-- CRUD 4 y 5: Recursos Humanos y Soporte Tecnico (2026-10-21).
USE portal_empleo_inclusivo;

ALTER TABLE usuarios
    MODIFY rol ENUM('ADMIN','POSTULANTE','EMPRESA','RECURSOS_HUMANOS','SOPORTE_TECNICO') NOT NULL;

CREATE TABLE IF NOT EXISTS evaluaciones_rrhh (
    id_evaluacion INT AUTO_INCREMENT PRIMARY KEY,
    id_postulacion INT NOT NULL,
    id_evaluador INT NOT NULL,
    observaciones VARCHAR(4000) NOT NULL,
    resultado ENUM('APROBADO','NO_APROBADO') NOT NULL,
    estado ENUM('BORRADOR','PUBLICADO') NOT NULL DEFAULT 'BORRADOR',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_evaluacion_rrhh (id_postulacion,id_evaluador),
    CONSTRAINT fk_evaluacion_postulacion FOREIGN KEY (id_postulacion)
        REFERENCES postulaciones(id_postulacion) ON DELETE CASCADE,
    CONSTRAINT fk_evaluacion_evaluador FOREIGN KEY (id_evaluador)
        REFERENCES usuarios(id_usuario)
);

CREATE TABLE IF NOT EXISTS incidencias_soporte (
    id_incidencia INT AUTO_INCREMENT PRIMARY KEY,
    id_creador INT NULL,
    id_responsable INT NOT NULL,
    correo VARCHAR(150) NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descripcion VARCHAR(4000) NOT NULL,
    origen ENUM('EXTERNA','INTERNA') NOT NULL DEFAULT 'EXTERNA',
    prioridad ENUM('BAJA','MEDIA','ALTA','URGENTE') NOT NULL DEFAULT 'MEDIA',
    decision ENUM('PENDIENTE','ACEPTADA','RECHAZADA') NOT NULL DEFAULT 'PENDIENTE',
    estado ENUM('PENDIENTE','EN_PROCESO','RESUELTA') NOT NULL DEFAULT 'PENDIENTE',
    solucion VARCHAR(4000) NOT NULL DEFAULT '',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_incidencia_creador FOREIGN KEY (id_creador)
        REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT fk_incidencia_responsable FOREIGN KEY (id_responsable)
        REFERENCES usuarios(id_usuario)
);

INSERT INTO usuarios(nombre,correo,contrasena,rol,estado)
VALUES ('Daniel Angel Advincula Miraval','daniel.advincula@incluyelab.com',
'pbkdf2$600000$M27ETomKEgpzEHzCwgWBIA==$6cu5f2NyPXGXO8dNvglqONdEEhgjzjPpobS3y8if0f4=',
'SOPORTE_TECNICO','activo')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre),rol=VALUES(rol),estado='activo';

INSERT INTO usuarios(nombre,correo,contrasena,rol,estado)
VALUES ('Marco Polo Salcedo Castillo','marco.salcedo@incluyelab.com',
'pbkdf2$600000$YEughiPdU0O7j8BhfRexiA==$dFI0SjRyPsRtdHoHhA9cphzKqM9GJGySANkRaFYcI7U=',
'RECURSOS_HUMANOS','activo')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre),rol=VALUES(rol),estado='activo';

