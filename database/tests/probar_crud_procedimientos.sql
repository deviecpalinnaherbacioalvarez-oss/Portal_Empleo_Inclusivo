-- Prueba reproducible de los cinco CRUD T2. Todo se revierte al finalizar.
USE portal_empleo_inclusivo;
START TRANSACTION;

SET @correo_prueba=CONCAT('crud-',REPLACE(UUID(),'-',''),'@incluyelab.test');
CALL sp_usuario_crear_interno('Cuenta temporal CRUD',@correo_prueba,'hash-temporal','SOPORTE_TECNICO','activo',@usuario_prueba);
CALL sp_usuario_listar();
CALL sp_usuario_actualizar_interno(@usuario_prueba,'Cuenta temporal actualizada',@correo_prueba,'','SOPORTE_TECNICO','activo');
CALL sp_usuario_eliminar(@usuario_prueba);

SET @empresa_prueba=(SELECT e.id_empresa FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA' ORDER BY e.id_empresa LIMIT 1);
CALL sp_oferta_crear(@empresa_prueba,'Oferta temporal CRUD','Remoto','Lima','Prueba transaccional','Registro temporal para verificar procedimientos.',1500.00,'lector');
SET @oferta_prueba=LAST_INSERT_ID();
CALL sp_oferta_listar_empresa(@empresa_prueba);
CALL sp_oferta_actualizar(@oferta_prueba,@empresa_prueba,'Oferta temporal actualizada','Hibrido','Lima','Prueba transaccional','Registro actualizado para verificar procedimientos.',1600.00,'lector,subtitulos','activa');

SET @postulante_prueba=(SELECT u.id_usuario FROM usuarios u JOIN verificaciones_conadis v ON v.id_usuario=u.id_usuario WHERE u.rol='POSTULANTE' AND u.estado='activo' AND v.estado='APROBADA' ORDER BY u.id_usuario LIMIT 1);
SET @empresa_usuario_prueba=(SELECT id_usuario FROM empresas WHERE id_empresa=@empresa_prueba);
CALL sp_postulacion_crear(@postulante_prueba,@oferta_prueba);
SET @postulacion_prueba=LAST_INSERT_ID();
CALL sp_postulacion_listar('USUARIO',@postulante_prueba,0);
CALL sp_postulacion_actualizar_empresa(@postulacion_prueba,@empresa_usuario_prueba,'en revision');

SET @rrhh_prueba=(SELECT id_usuario FROM usuarios WHERE rol='RECURSOS_HUMANOS' AND estado='activo' ORDER BY id_usuario LIMIT 1);
CALL sp_evaluacion_crear(@postulacion_prueba,@rrhh_prueba,'Evaluación temporal','Retroalimentación temporal','PENDIENTE','BORRADOR','REVISION_CV',70,60,50,65);
SET @evaluacion_prueba=LAST_INSERT_ID();
CALL sp_evaluacion_listar('ACTOR',@rrhh_prueba);
CALL sp_evaluacion_actualizar(@evaluacion_prueba,@postulacion_prueba,@rrhh_prueba,'Evaluación actualizada','Retroalimentación actualizada','PENDIENTE','BORRADOR','ENTREVISTA',75,70,55,70);
CALL sp_evaluacion_eliminar(@evaluacion_prueba,@rrhh_prueba);
CALL sp_postulacion_eliminar_usuario(@postulacion_prueba,@postulante_prueba);
CALL sp_oferta_cerrar(@oferta_prueba,@empresa_prueba);

SET @soporte_prueba=(SELECT id_usuario FROM usuarios WHERE rol='SOPORTE_TECNICO' AND estado='activo' ORDER BY id_usuario LIMIT 1);
CALL sp_incidencia_crear_interna(@soporte_prueba,'ACCESO','Incidencia temporal CRUD','Registro temporal para verificar procedimientos.','BAJA');
SET @incidencia_prueba=LAST_INSERT_ID();
CALL sp_incidencia_listar('ACTOR',@soporte_prueba);
CALL sp_incidencia_actualizar(@soporte_prueba,@incidencia_prueba,'Incidencia temporal actualizada','Descripción actualizada.','ACCESO','MEDIA','PENDIENTE','PENDIENTE','');
CALL sp_incidencia_eliminar(@soporte_prueba,@incidencia_prueba);

ROLLBACK;
SELECT IF(
    EXISTS(
        SELECT 1
        FROM usuarios
        WHERE correo = CONVERT(@correo_prueba USING utf8mb4) COLLATE utf8mb4_unicode_ci
    ),
    'ERROR_QUEDARON_DATOS',
    'CRUD_5_OK_ROLLBACK_LIMPIO'
) AS resultado;
