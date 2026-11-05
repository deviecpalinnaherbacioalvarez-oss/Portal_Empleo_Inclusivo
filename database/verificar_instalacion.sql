-- Comprobacion de solo lectura para la instalacion actual de IncluyeLab.
USE portal_empleo_inclusivo;

DROP TEMPORARY TABLE IF EXISTS procedimientos_esperados;
CREATE TEMPORARY TABLE procedimientos_esperados(nombre VARCHAR(80) PRIMARY KEY);
INSERT INTO procedimientos_esperados(nombre) VALUES
('sp_usuario_listar'),('sp_usuario_crear_interno'),('sp_usuario_actualizar_interno'),('sp_usuario_eliminar'),('sp_usuario_desactivar'),
('sp_oferta_listar_empresa'),('sp_oferta_listar_todas'),('sp_oferta_listar_publicas'),('sp_oferta_crear'),('sp_oferta_actualizar'),('sp_oferta_cerrar'),
('sp_postulacion_listar'),('sp_postulacion_crear'),('sp_postulacion_actualizar_empresa'),('sp_postulacion_eliminar_usuario'),('sp_postulacion_eliminar_empresa'),
('sp_evaluacion_listar'),('sp_evaluacion_crear'),('sp_evaluacion_actualizar'),('sp_evaluacion_eliminar'),
('sp_incidencia_listar'),('sp_incidencia_crear_interna'),('sp_incidencia_crear_externa'),('sp_incidencia_actualizar'),('sp_incidencia_eliminar');

SELECT requisito
FROM (
    SELECT 'tabla discapacidades' requisito, EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='discapacidades') ok
    UNION ALL SELECT 'tabla verificaciones_conadis',EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis')
    UNION ALL SELECT 'tabla historial_verificaciones_conadis',EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='historial_verificaciones_conadis')
    UNION ALL SELECT 'tabla auditoria_soporte',EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='auditoria_soporte')
    UNION ALL SELECT 'tabla mensajes_postulacion',EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='mensajes_postulacion')
    UNION ALL SELECT 'usuarios.clave_temporal_expira',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='clave_temporal_expira')
    UNION ALL SELECT 'usuarios.requiere_cambio_clave',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='requiere_cambio_clave')
    UNION ALL SELECT 'codigos_otp.codigo admite hash',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='codigos_otp' AND column_name='codigo' AND character_maximum_length>=255)
    UNION ALL SELECT 'sin padron CONADIS ficticio',NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='padron_conadis')
    UNION ALL SELECT 'verificaciones_conadis.id_discapacidad',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='id_discapacidad')
    UNION ALL SELECT 'verificaciones_conadis.rui obligatorio',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='rui' AND is_nullable='NO')
    UNION ALL SELECT 'verificaciones_conadis.consentimiento obligatorio',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='consentimiento_datos_at' AND is_nullable='NO')
    UNION ALL SELECT 'incidencias_soporte.numero_ticket',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='numero_ticket')
    UNION ALL SELECT 'ofertas.apoyos',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='ofertas' AND column_name='apoyos')
    UNION ALL SELECT 'empresas.sitio_oficial',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='sitio_oficial')
    UNION ALL SELECT 'trigger CONADIS insertar',EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bi_conadis_obligatoria')
    UNION ALL SELECT 'trigger CONADIS actualizar',EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bu_conadis_obligatoria')
    UNION ALL SELECT 'trigger CONADIS eliminar',EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bd_conadis_auditada')
    UNION ALL SELECT '25 procedimientos CRUD T2 con nombres exactos',NOT EXISTS(SELECT 1 FROM procedimientos_esperados p WHERE NOT EXISTS(SELECT 1 FROM information_schema.routines r WHERE r.routine_schema=DATABASE() AND r.routine_type='PROCEDURE' AND r.routine_name=p.nombre))
) comprobaciones
WHERE ok=0;

SELECT IF(SUM(ok)=COUNT(*),'INSTALACION_COMPLETA','INSTALACION_INCOMPLETA') AS resultado,
       SUM(ok) AS requisitos_correctos,COUNT(*) AS requisitos_totales
FROM (
    SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='discapacidades') ok
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='historial_verificaciones_conadis')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='auditoria_soporte')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='mensajes_postulacion')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='clave_temporal_expira')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='requiere_cambio_clave')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='codigos_otp' AND column_name='codigo' AND character_maximum_length>=255)
    UNION ALL SELECT NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='padron_conadis')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='id_discapacidad')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='rui' AND is_nullable='NO')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='consentimiento_datos_at' AND is_nullable='NO')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='numero_ticket')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='ofertas' AND column_name='apoyos')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='sitio_oficial')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bi_conadis_obligatoria')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bu_conadis_obligatoria')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bd_conadis_auditada')
    UNION ALL SELECT NOT EXISTS(SELECT 1 FROM procedimientos_esperados p WHERE NOT EXISTS(SELECT 1 FROM information_schema.routines r WHERE r.routine_schema=DATABASE() AND r.routine_type='PROCEDURE' AND r.routine_name=p.nombre))
) comprobaciones;

SELECT p.nombre AS procedimiento_faltante
FROM procedimientos_esperados p
WHERE NOT EXISTS(SELECT 1 FROM information_schema.routines r WHERE r.routine_schema=DATABASE() AND r.routine_type='PROCEDURE' AND r.routine_name=p.nombre);
