-- Catálogo de las 13 discapacidades o necesidades de IncluyeLab.
-- Conserva usuarios, perfiles, ofertas y postulaciones.
SET NAMES utf8mb4;
USE portal_empleo_inclusivo;

CREATE TABLE IF NOT EXISTS discapacidades (
    id_discapacidad TINYINT UNSIGNED NOT NULL,
    codigo VARCHAR(40) NOT NULL,
    nombre VARCHAR(180) NOT NULL,
    PRIMARY KEY (id_discapacidad),
    UNIQUE KEY uk_discapacidades_codigo (codigo),
    UNIQUE KEY uk_discapacidades_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO discapacidades (id_discapacidad, codigo, nombre)
VALUES
    (1, 'visual', 'Visual (ceguera o baja visión)'),
    (2, 'fisica_motora', 'Física o motora'),
    (3, 'auditiva', 'Auditiva (sordera o hipoacusia)'),
    (4, 'intelectual', 'Intelectual'),
    (5, 'habla', 'Dificultades del habla (afasia, disartria, etc.)'),
    (6, 'autismo_sensorial', 'Autismo con necesidades sensoriales'),
    (7, 'dislexia', 'Dislexia y dificultades de lectura'),
    (8, 'movilidad_manual', 'Movilidad manual muy limitada'),
    (9, 'sordoceguera', 'Sordoceguera'),
    (10, 'psicosocial', 'Psicosocial'),
    (11, 'tdah', 'TDAH con necesidades de apoyo'),
    (12, 'cronicas_fatiga', 'Discapacidades asociadas a condiciones crónicas o fatiga'),
    (13, 'fotosensibilidad', 'Fotosensibilidad o sensibilidad a estímulos visuales');
