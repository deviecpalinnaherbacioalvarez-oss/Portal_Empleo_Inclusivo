USE portal_empleo_inclusivo;

-- Integra los carnets y CV demostrativos protegidos de Sofia y Luis.
-- Requiere el esquema consolidado 2026.10.31, una instalacion nueva o la
-- migracion 20261103_actualizar_reglas_conadis.sql. Esta
-- migracion no sustituye triggers ni modifica solicitudes ajenas a estas cuentas.

SET @sofia=(SELECT id_usuario FROM usuarios WHERE correo='sofia@correo.com' AND rol='POSTULANTE' LIMIT 1);
SET @luis=(SELECT id_usuario FROM usuarios WHERE correo='luis@correo.com' AND rol='POSTULANTE' LIMIT 1);
SET @rrhh=(SELECT id_usuario FROM usuarios WHERE rol='RECURSOS_HUMANOS' AND estado='activo' ORDER BY id_usuario LIMIT 1);

INSERT INTO verificaciones_conadis(id_usuario,rui,carnet_archivo,estado,observacion_sistema,revision_rrhh,fecha_envio,consentimiento_datos_at)
SELECT @sofia,'406923','demo:conadis-sofia-ramirez.png','PENDIENTE','Solicitud demostrativa pendiente de revision manual.',1,NOW(),NOW()
WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM verificaciones_conadis WHERE id_usuario=@sofia);
INSERT INTO verificaciones_conadis(id_usuario,rui,carnet_archivo,estado,observacion_sistema,revision_rrhh,fecha_envio,consentimiento_datos_at)
SELECT @luis,'406924','demo:conadis-luis-torres.png','PENDIENTE','Solicitud demostrativa pendiente de revision manual.',1,NOW(),NOW()
WHERE @luis IS NOT NULL AND NOT EXISTS(SELECT 1 FROM verificaciones_conadis WHERE id_usuario=@luis);

UPDATE verificaciones_conadis SET rui='406923',dni='70568033',apellidos='RAMIREZ QUISPE',nombres='SOFIA VALERIA',carnet_archivo='demo:conadis-sofia-ramirez.png',fecha_caducidad='2030-12-31',estado='APROBADA',metodo='MANUAL',motivo='Registro demostrativo revisado por Recursos Humanos.',id_revisor=@rrhh,fecha_revision=NOW(),revision_rrhh=1,observacion_sistema='Revision manual de datos demostrativos; no equivale a una consulta oficial en linea.',consentimiento_datos_at=COALESCE(consentimiento_datos_at,NOW()) WHERE id_usuario=@sofia AND @rrhh IS NOT NULL;
UPDATE verificaciones_conadis SET rui='406924',dni='45687643',apellidos='TORRES MEDINA',nombres='LUIS ALBERTO',carnet_archivo='demo:conadis-luis-torres.png',fecha_caducidad='2030-12-31',estado='APROBADA',metodo='MANUAL',motivo='Registro demostrativo revisado por Recursos Humanos.',id_revisor=@rrhh,fecha_revision=NOW(),revision_rrhh=1,observacion_sistema='Revision manual de datos demostrativos; no equivale a una consulta oficial en linea.',consentimiento_datos_at=COALESCE(consentimiento_datos_at,NOW()) WHERE id_usuario=@luis AND @rrhh IS NOT NULL;

INSERT INTO historial_verificaciones_conadis(id_verificacion,id_usuario,rui,carnet_archivo,estado,motivo,id_revisor,accion,fecha_evento)
SELECT v.id_verificacion,v.id_usuario,v.rui,v.carnet_archivo,v.estado,v.motivo,v.id_revisor,'DATOS_DEMO_INTEGRADOS',NOW() FROM verificaciones_conadis v WHERE v.id_usuario IN (@sofia,@luis) AND NOT EXISTS(SELECT 1 FROM historial_verificaciones_conadis h WHERE h.id_verificacion=v.id_verificacion AND h.accion='DATOS_DEMO_INTEGRADOS');

INSERT INTO perfiles_postulantes(id_usuario,dni,telefono,habilidades,adaptacion_requerida,titular,ubicacion,acerca_de,cv_nombre,cv_archivo,cv_actualizado)
SELECT @sofia,'70568033','999111222','Java, MySQL, HTML, CSS, Bootstrap, soporte TI, trabajo en equipo','Indicaciones escritas, acceso fisico y modalidad hibrida','Estudiante de Ingenieria de Sistemas | Java, MySQL y soporte TI','San Juan de Lurigancho, Lima','Estudiante de Ingenieria de Sistemas interesada en desarrollo web, bases de datos y soporte tecnologico. Busca aportar en proyectos accesibles mediante documentacion clara, pruebas funcionales y trabajo colaborativo.','CV_Sofia_Ramirez.pdf','demo:cv-sofia-ramirez.pdf',NOW() WHERE @sofia IS NOT NULL ON DUPLICATE KEY UPDATE dni=VALUES(dni),telefono=VALUES(telefono),habilidades=VALUES(habilidades),adaptacion_requerida=VALUES(adaptacion_requerida),titular=VALUES(titular),ubicacion=VALUES(ubicacion),acerca_de=VALUES(acerca_de),cv_nombre=VALUES(cv_nombre),cv_archivo=VALUES(cv_archivo),cv_actualizado=NOW();
INSERT INTO perfiles_postulantes(id_usuario,dni,telefono,habilidades,adaptacion_requerida,titular,ubicacion,acerca_de,cv_nombre,cv_archivo,cv_actualizado)
SELECT @luis,'45687643','988777666','Diseno grafico, redes sociales, redaccion y comunicacion digital','Compatibilidad con lector de pantalla, documentos accesibles y comunicacion escrita','Asistente de comunicacion digital | Diseno grafico y redes sociales','Lima, Peru','Postulante orientado a la comunicacion digital, el diseno de piezas visuales accesibles y la gestion de contenidos para redes sociales. Destaca por su redaccion clara, organizacion y disposicion para aprender.','CV_Luis_Torres.pdf','demo:cv-luis-torres.pdf',NOW() WHERE @luis IS NOT NULL ON DUPLICATE KEY UPDATE dni=VALUES(dni),telefono=VALUES(telefono),habilidades=VALUES(habilidades),adaptacion_requerida=VALUES(adaptacion_requerida),titular=VALUES(titular),ubicacion=VALUES(ubicacion),acerca_de=VALUES(acerca_de),cv_nombre=VALUES(cv_nombre),cv_archivo=VALUES(cv_archivo),cv_actualizado=NOW();

INSERT INTO experiencias_postulante(id_usuario,cargo,organizacion,fecha_inicio,fecha_fin,descripcion) SELECT @luis,'Practicante de comunicacion digital','Proyecto academico IncluyeLab','May. 2026','Oct. 2026','Experiencia demostrativa en redaccion de contenidos, preparacion de piezas graficas accesibles y apoyo en la organizacion de publicaciones para redes sociales.' WHERE @luis IS NOT NULL AND NOT EXISTS(SELECT 1 FROM experiencias_postulante WHERE id_usuario=@luis AND organizacion='Proyecto academico IncluyeLab');
INSERT INTO educacion_postulante(id_usuario,institucion,carrera,fecha_inicio,fecha_fin,descripcion) SELECT @luis,'Programa academico de demostracion IncluyeLab','Comunicacion digital y diseno grafico','Mar. 2025','Actualidad','Formacion demostrativa en redaccion digital, composicion visual, contenidos para redes sociales y accesibilidad de documentos.' WHERE @luis IS NOT NULL AND NOT EXISTS(SELECT 1 FROM educacion_postulante WHERE id_usuario=@luis AND institucion='Programa academico de demostracion IncluyeLab');
INSERT INTO certificaciones_postulante(id_usuario,nombre,emisor,fecha_emision,credencial_url) SELECT @luis,'Diseno de contenido digital accesible','IncluyeLab - contenido demostrativo','Sep. 2026','' WHERE @luis IS NOT NULL AND NOT EXISTS(SELECT 1 FROM certificaciones_postulante WHERE id_usuario=@luis AND nombre='Diseno de contenido digital accesible');

INSERT INTO esquema_version(version) VALUES ('2026.11.03') ON DUPLICATE KEY UPDATE fecha_aplicacion=CURRENT_TIMESTAMP;
