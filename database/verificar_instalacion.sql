-- Comprobacion de solo lectura para la instalacion actual de IncluyeLab.
USE portal_empleo_inclusivo;

SELECT requisito
FROM (
    SELECT 'tabla discapacidades' requisito, EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='discapacidades') ok
    UNION ALL SELECT 'tabla verificaciones_conadis',EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis')
    UNION ALL SELECT 'tabla historial_verificaciones_conadis',EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='historial_verificaciones_conadis')
    UNION ALL SELECT 'tabla auditoria_soporte',EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='auditoria_soporte')
    UNION ALL SELECT 'usuarios.clave_temporal_expira',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='clave_temporal_expira')
    UNION ALL SELECT 'usuarios.requiere_cambio_clave',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='requiere_cambio_clave')
    UNION ALL SELECT 'verificaciones_conadis.id_discapacidad',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='id_discapacidad')
    UNION ALL SELECT 'incidencias_soporte.numero_ticket',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='numero_ticket')
    UNION ALL SELECT 'ofertas.apoyos',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='ofertas' AND column_name='apoyos')
    UNION ALL SELECT 'empresas.sitio_oficial',EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='sitio_oficial')
    UNION ALL SELECT 'trigger CONADIS insertar',EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bi_conadis_obligatoria')
    UNION ALL SELECT 'trigger CONADIS actualizar',EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bu_conadis_obligatoria')
    UNION ALL SELECT 'trigger CONADIS eliminar',EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bd_conadis_auditada')
) comprobaciones
WHERE ok=0;

SELECT IF(SUM(ok)=COUNT(*),'INSTALACION_COMPLETA','INSTALACION_INCOMPLETA') AS resultado,
       SUM(ok) AS requisitos_correctos,COUNT(*) AS requisitos_totales
FROM (
    SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='discapacidades') ok
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='historial_verificaciones_conadis')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='auditoria_soporte')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='clave_temporal_expira')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='requiere_cambio_clave')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='id_discapacidad')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='numero_ticket')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='ofertas' AND column_name='apoyos')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='sitio_oficial')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bi_conadis_obligatoria')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bu_conadis_obligatoria')
    UNION ALL SELECT EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='bd_conadis_auditada')
) comprobaciones;
