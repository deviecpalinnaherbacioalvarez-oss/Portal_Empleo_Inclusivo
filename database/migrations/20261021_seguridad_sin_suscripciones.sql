-- Retira la simulacion de suscripciones y enfoca Soporte en seguridad y reportes.
USE portal_empleo_inclusivo;

UPDATE incidencias_soporte SET categoria='OTRO' WHERE categoria='FACTURACION';
ALTER TABLE incidencias_soporte
    MODIFY categoria ENUM('SEGURIDAD','ACCESO','INFRACCION','TECNICO','OTRO') NOT NULL DEFAULT 'TECNICO';

DROP TABLE IF EXISTS pagos_simulados;
DROP TABLE IF EXISTS suscripciones;
DROP TABLE IF EXISTS planes_suscripcion;
