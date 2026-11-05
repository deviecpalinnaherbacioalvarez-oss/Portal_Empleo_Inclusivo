USE portal_empleo_inclusivo;

-- T2: cinco CRUD reales implementados mediante Stored Procedures.
-- Las validaciones de formato y rol se mantienen tambien en los DAO/Servlets.
DROP PROCEDURE IF EXISTS sp_usuario_listar;
DROP PROCEDURE IF EXISTS sp_usuario_crear_interno;
DROP PROCEDURE IF EXISTS sp_usuario_actualizar_interno;
DROP PROCEDURE IF EXISTS sp_usuario_eliminar;
DROP PROCEDURE IF EXISTS sp_usuario_desactivar;
DROP PROCEDURE IF EXISTS sp_oferta_listar_empresa;
DROP PROCEDURE IF EXISTS sp_oferta_listar_todas;
DROP PROCEDURE IF EXISTS sp_oferta_listar_publicas;
DROP PROCEDURE IF EXISTS sp_oferta_crear;
DROP PROCEDURE IF EXISTS sp_oferta_actualizar;
DROP PROCEDURE IF EXISTS sp_oferta_cerrar;
DROP PROCEDURE IF EXISTS sp_postulacion_listar;
DROP PROCEDURE IF EXISTS sp_postulacion_crear;
DROP PROCEDURE IF EXISTS sp_postulacion_actualizar_empresa;
DROP PROCEDURE IF EXISTS sp_postulacion_eliminar_usuario;
DROP PROCEDURE IF EXISTS sp_postulacion_eliminar_empresa;
DROP PROCEDURE IF EXISTS sp_evaluacion_listar;
DROP PROCEDURE IF EXISTS sp_evaluacion_crear;
DROP PROCEDURE IF EXISTS sp_evaluacion_actualizar;
DROP PROCEDURE IF EXISTS sp_evaluacion_eliminar;
DROP PROCEDURE IF EXISTS sp_incidencia_listar;
DROP PROCEDURE IF EXISTS sp_incidencia_crear_interna;
DROP PROCEDURE IF EXISTS sp_incidencia_crear_externa;
DROP PROCEDURE IF EXISTS sp_incidencia_actualizar;
DROP PROCEDURE IF EXISTS sp_incidencia_eliminar;

DELIMITER $$

CREATE PROCEDURE sp_usuario_listar()
BEGIN
  SELECT id_usuario,nombre,correo,rol,estado,requiere_cambio_clave,correo_verificado
  FROM usuarios ORDER BY id_usuario DESC;
END$$

CREATE PROCEDURE sp_usuario_crear_interno(IN p_nombre VARCHAR(120),IN p_correo VARCHAR(150),IN p_hash VARCHAR(255),IN p_rol VARCHAR(40),IN p_estado VARCHAR(10),OUT p_id INT)
BEGIN
  INSERT INTO usuarios(nombre,correo,contrasena,rol,estado) VALUES(p_nombre,p_correo,p_hash,p_rol,p_estado);
  SET p_id=LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_usuario_actualizar_interno(IN p_id INT,IN p_nombre VARCHAR(120),IN p_correo VARCHAR(150),IN p_hash VARCHAR(255),IN p_rol VARCHAR(40),IN p_estado VARCHAR(10))
BEGIN
  IF NOT EXISTS(SELECT 1 FROM usuarios WHERE id_usuario=p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cuenta ya no existe.'; END IF;
  UPDATE usuarios SET nombre=p_nombre,correo=p_correo,rol=p_rol,estado=p_estado,
    contrasena=IF(p_hash IS NULL OR p_hash='',contrasena,p_hash),
    intentos_fallidos=IF(p_hash IS NULL OR p_hash='',intentos_fallidos,0),
    bloqueado_hasta=IF(p_hash IS NULL OR p_hash='',bloqueado_hasta,NULL)
  WHERE id_usuario=p_id;
END$$

CREATE PROCEDURE sp_usuario_eliminar(IN p_id INT)
BEGIN
  DELETE FROM usuarios WHERE id_usuario=p_id;
  IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cuenta ya no existe.'; END IF;
END$$

CREATE PROCEDURE sp_usuario_desactivar(IN p_id INT)
BEGIN
  UPDATE usuarios SET estado='inactivo',bloqueado_hasta=NULL WHERE id_usuario=p_id AND estado='activo';
  IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cuenta ya esta inactiva o no existe.'; END IF;
END$$

CREATE PROCEDURE sp_oferta_listar_empresa(IN p_empresa INT)
BEGIN
  SELECT o.id_oferta,o.id_empresa,e.razon_social empresa,e.logo_url,o.titulo,o.modalidad,o.ubicacion,o.adaptaciones,o.apoyos,o.descripcion,o.salario,o.estado
  FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa WHERE o.id_empresa=p_empresa ORDER BY o.id_oferta DESC;
END$$

CREATE PROCEDURE sp_oferta_listar_todas()
BEGIN
  SELECT o.id_oferta,o.id_empresa,e.razon_social empresa,e.logo_url,o.titulo,o.modalidad,o.ubicacion,o.adaptaciones,o.apoyos,o.descripcion,o.salario,o.estado
  FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa ORDER BY o.id_oferta DESC;
END$$

CREATE PROCEDURE sp_oferta_listar_publicas()
BEGIN
  SELECT o.id_oferta,o.id_empresa,e.razon_social empresa,e.logo_url,o.titulo,o.modalidad,o.ubicacion,
         o.adaptaciones,o.apoyos,o.descripcion,o.salario,o.estado
  FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa JOIN usuarios u ON u.id_usuario=e.id_usuario
  WHERE o.estado='activa' AND o.fecha_publicacion<=NOW() AND e.estado_revision='aprobada'
    AND u.estado='activo' AND u.rol='EMPRESA'
  ORDER BY o.id_oferta DESC;
END$$

CREATE PROCEDURE sp_oferta_crear(IN p_empresa INT,IN p_titulo VARCHAR(150),IN p_modalidad VARCHAR(80),IN p_ubicacion VARCHAR(120),IN p_adaptaciones VARCHAR(255),IN p_descripcion TEXT,IN p_salario DECIMAL(10,2),IN p_apoyos VARCHAR(500))
BEGIN
  INSERT INTO ofertas(id_empresa,titulo,modalidad,ubicacion,adaptaciones,descripcion,salario,apoyos,estado)
  SELECT p_empresa,p_titulo,p_modalidad,p_ubicacion,p_adaptaciones,p_descripcion,p_salario,p_apoyos,'activa'
  FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario
  WHERE e.id_empresa=p_empresa AND e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA';
  IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La empresa requiere aprobacion antes de publicar.'; END IF;
END$$

CREATE PROCEDURE sp_oferta_actualizar(IN p_id INT,IN p_empresa INT,IN p_titulo VARCHAR(150),IN p_modalidad VARCHAR(80),IN p_ubicacion VARCHAR(120),IN p_adaptaciones VARCHAR(255),IN p_descripcion TEXT,IN p_salario DECIMAL(10,2),IN p_apoyos VARCHAR(500),IN p_estado VARCHAR(10))
BEGIN
  IF NOT EXISTS(SELECT 1 FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE o.id_oferta=p_id AND o.id_empresa=p_empresa AND e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La oferta no existe o no pertenece a la empresa.'; END IF;
  UPDATE ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa JOIN usuarios u ON u.id_usuario=e.id_usuario
  SET o.titulo=p_titulo,o.modalidad=p_modalidad,o.ubicacion=p_ubicacion,o.adaptaciones=p_adaptaciones,o.descripcion=p_descripcion,o.salario=p_salario,o.apoyos=p_apoyos,o.estado=p_estado
  WHERE o.id_oferta=p_id AND o.id_empresa=p_empresa AND e.estado_revision='aprobada' AND u.estado='activo' AND u.rol='EMPRESA';
END$$

CREATE PROCEDURE sp_oferta_cerrar(IN p_id INT,IN p_empresa INT)
BEGIN
  IF NOT EXISTS(SELECT 1 FROM ofertas WHERE id_oferta=p_id AND id_empresa=p_empresa AND estado='activa') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La oferta no existe, no pertenece a la empresa o ya esta cerrada.';
  END IF;
  INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje)
  SELECT p.id_usuario,'OFERTA_ELIMINADA','Oferta cerrada',CONCAT('La empresa cerro una oferta a la que habias postulado. Tu historial se conserva. Puesto: ',o.titulo)
  FROM postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta WHERE p.id_oferta=p_id;
  UPDATE ofertas SET estado='cerrada' WHERE id_oferta=p_id AND id_empresa=p_empresa;
END$$

CREATE PROCEDURE sp_postulacion_listar(IN p_modo VARCHAR(20),IN p_id1 INT,IN p_id2 INT)
BEGIN
  SELECT p.id_postulacion,p.id_usuario,p.id_oferta,u.nombre postulante,u.correo,o.titulo oferta,e.razon_social empresa,p.estado,
    DATE_FORMAT(p.fecha_postulacion,'%d/%m/%Y %H:%i') fecha_postulacion,COALESCE(pp.titular,'') titular,
    COALESCE(pp.ubicacion,'') ubicacion,COALESCE(pp.habilidades,'') habilidades,COALESCE(pp.cv_nombre,'') cv_nombre
  FROM postulaciones p JOIN usuarios u ON u.id_usuario=p.id_usuario JOIN ofertas o ON o.id_oferta=p.id_oferta
  JOIN empresas e ON e.id_empresa=o.id_empresa LEFT JOIN perfiles_postulantes pp ON pp.id_usuario=u.id_usuario
  WHERE p_modo='TODAS' OR (p_modo='USUARIO' AND p.id_usuario=p_id1) OR (p_modo='EMPRESA' AND e.id_usuario=p_id1)
    OR (p_modo='ID' AND p.id_postulacion=p_id1) OR (p_modo='EMPRESA_ID' AND p.id_postulacion=p_id1 AND e.id_usuario=p_id2)
  ORDER BY p.id_postulacion DESC;
END$$

CREATE PROCEDURE sp_postulacion_crear(IN p_usuario INT,IN p_oferta INT)
BEGIN
  INSERT INTO postulaciones(id_usuario,id_oferta,estado)
  SELECT p_usuario,o.id_oferta,'pendiente' FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa
  JOIN usuarios ue ON ue.id_usuario=e.id_usuario JOIN usuarios up ON up.id_usuario=p_usuario AND up.rol='POSTULANTE' AND up.estado='activo'
  JOIN verificaciones_conadis vc ON vc.id_usuario=up.id_usuario AND vc.estado='APROBADA' AND (vc.fecha_caducidad IS NULL OR vc.fecha_caducidad>=CURDATE())
  WHERE o.id_oferta=p_oferta AND o.estado='activa' AND e.estado_revision='aprobada' AND ue.estado='activo' AND ue.rol='EMPRESA'
    AND NOT EXISTS(SELECT 1 FROM postulaciones p WHERE p.id_usuario=p_usuario AND p.id_oferta=o.id_oferta);
  IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La oferta no esta disponible o ya existe la postulacion.'; END IF;
END$$

CREATE PROCEDURE sp_postulacion_actualizar_empresa(IN p_id INT,IN p_empresa_usuario INT,IN p_estado VARCHAR(20))
BEGIN
  IF NOT EXISTS(SELECT 1 FROM postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa WHERE p.id_postulacion=p_id AND e.id_usuario=p_empresa_usuario) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Postulacion no disponible.'; END IF;
  UPDATE postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa
  SET p.estado=p_estado WHERE p.id_postulacion=p_id AND e.id_usuario=p_empresa_usuario;
END$$

CREATE PROCEDURE sp_postulacion_eliminar_usuario(IN p_id INT,IN p_usuario INT)
BEGIN
  IF NOT EXISTS(SELECT 1 FROM postulaciones WHERE id_postulacion=p_id AND id_usuario=p_usuario) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Postulacion no disponible.'; END IF;
  DELETE FROM evaluaciones_rrhh WHERE id_postulacion=p_id;
  DELETE FROM postulaciones WHERE id_postulacion=p_id;
END$$

CREATE PROCEDURE sp_postulacion_eliminar_empresa(IN p_id INT,IN p_empresa_usuario INT)
BEGIN
  IF NOT EXISTS(SELECT 1 FROM postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa WHERE p.id_postulacion=p_id AND e.id_usuario=p_empresa_usuario) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Postulacion no disponible.'; END IF;
  INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje)
  SELECT p.id_usuario,'POSTULACION_ELIMINADA','Postulacion eliminada',CONCAT('La empresa ',e.razon_social,' elimino tu postulacion a ',o.titulo,'.')
  FROM postulaciones p JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa WHERE p.id_postulacion=p_id;
  DELETE FROM evaluaciones_rrhh WHERE id_postulacion=p_id;
  DELETE FROM postulaciones WHERE id_postulacion=p_id;
END$$

CREATE PROCEDURE sp_evaluacion_listar(IN p_modo VARCHAR(10),IN p_actor INT)
BEGIN
  SELECT v.id_evaluacion,v.id_postulacion,v.id_evaluador,u.nombre nombre_postulante,ev.nombre nombre_evaluador,o.titulo titulo_oferta,
    e.razon_social razon_social_empresa,v.observaciones,v.retroalimentacion,v.resultado,v.estado,v.etapa,v.puntaje_cv,
    v.puntaje_entrevista,v.puntaje_desempeno,v.porcentaje_compatibilidad,v.fecha_creacion,v.fecha_actualizacion
  FROM evaluaciones_rrhh v JOIN postulaciones p ON p.id_postulacion=v.id_postulacion JOIN usuarios u ON u.id_usuario=p.id_usuario
  JOIN usuarios ev ON ev.id_usuario=v.id_evaluador JOIN ofertas o ON o.id_oferta=p.id_oferta JOIN empresas e ON e.id_empresa=o.id_empresa
  WHERE p_modo='TODAS' OR (p_modo='ACTOR' AND v.id_evaluador=p_actor) ORDER BY v.id_evaluacion DESC;
END$$

CREATE PROCEDURE sp_evaluacion_crear(IN p_postulacion INT,IN p_actor INT,IN p_observaciones VARCHAR(4000),IN p_retroalimentacion VARCHAR(4000),IN p_resultado VARCHAR(20),IN p_estado VARCHAR(20),IN p_etapa VARCHAR(30),IN p_cv INT,IN p_entrevista INT,IN p_desempeno INT,IN p_compatibilidad INT)
BEGIN
  INSERT INTO evaluaciones_rrhh(id_postulacion,id_evaluador,observaciones,retroalimentacion,resultado,estado,etapa,puntaje_cv,puntaje_entrevista,puntaje_desempeno,porcentaje_compatibilidad)
  VALUES(p_postulacion,p_actor,p_observaciones,p_retroalimentacion,p_resultado,p_estado,p_etapa,p_cv,p_entrevista,p_desempeno,p_compatibilidad);
END$$

CREATE PROCEDURE sp_evaluacion_actualizar(IN p_id INT,IN p_postulacion INT,IN p_actor INT,IN p_observaciones VARCHAR(4000),IN p_retroalimentacion VARCHAR(4000),IN p_resultado VARCHAR(20),IN p_estado VARCHAR(20),IN p_etapa VARCHAR(30),IN p_cv INT,IN p_entrevista INT,IN p_desempeno INT,IN p_compatibilidad INT)
BEGIN
  IF NOT EXISTS(SELECT 1 FROM evaluaciones_rrhh WHERE id_evaluacion=p_id AND id_evaluador=p_actor) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Evaluacion no disponible.'; END IF;
  UPDATE evaluaciones_rrhh SET id_postulacion=p_postulacion,observaciones=p_observaciones,retroalimentacion=p_retroalimentacion,
    resultado=p_resultado,estado=p_estado,etapa=p_etapa,puntaje_cv=p_cv,puntaje_entrevista=p_entrevista,puntaje_desempeno=p_desempeno,porcentaje_compatibilidad=p_compatibilidad
  WHERE id_evaluacion=p_id AND id_evaluador=p_actor;
END$$

CREATE PROCEDURE sp_evaluacion_eliminar(IN p_id INT,IN p_actor INT)
BEGIN
  DELETE FROM evaluaciones_rrhh WHERE id_evaluacion=p_id AND id_evaluador=p_actor AND estado='BORRADOR';
  IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se eliminan evaluaciones propias en borrador.'; END IF;
END$$

CREATE PROCEDURE sp_incidencia_listar(IN p_modo VARCHAR(10),IN p_actor INT)
BEGIN
  SELECT i.*,ua.nombre nombre_usuario_afectado,ur.nombre nombre_responsable,ua.estado estado_cuenta,
    COALESCE(ua.intentos_fallidos,0) intentos_fallidos,ua.bloqueado_hasta,COALESCE(ua.motivo_bloqueo,'') motivo_bloqueo
  FROM incidencias_soporte i LEFT JOIN usuarios ua ON ua.id_usuario=i.id_usuario_afectado JOIN usuarios ur ON ur.id_usuario=i.id_responsable
  WHERE p_modo='TODAS' OR (p_modo='ACTOR' AND i.id_responsable=p_actor)
  ORDER BY FIELD(i.prioridad,'URGENTE','ALTA','MEDIA','BAJA'),i.id_incidencia DESC;
END$$

CREATE PROCEDURE sp_incidencia_crear_interna(IN p_actor INT,IN p_categoria VARCHAR(20),IN p_titulo VARCHAR(150),IN p_descripcion VARCHAR(4000),IN p_prioridad VARCHAR(10))
BEGIN
  INSERT INTO incidencias_soporte(id_creador,id_responsable,correo,titulo,descripcion,origen,categoria,prioridad,decision,estado,numero_ticket)
  SELECT id_usuario,id_usuario,correo,p_titulo,p_descripcion,'INTERNA',p_categoria,p_prioridad,'PENDIENTE','PENDIENTE',CONCAT('TMP-',LEFT(REPLACE(UUID(),'-',''),26))
  FROM usuarios WHERE id_usuario=p_actor AND rol='SOPORTE_TECNICO' AND estado='activo';
  IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cuenta no tiene acceso de Soporte.'; END IF;
  UPDATE incidencias_soporte SET numero_ticket=CONCAT('INC-',LPAD(id_incidencia,8,'0')) WHERE id_incidencia=LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_incidencia_crear_externa(IN p_creador INT,IN p_correo VARCHAR(150),IN p_categoria VARCHAR(20),IN p_titulo VARCHAR(150),IN p_descripcion VARCHAR(4000),OUT p_id INT)
BEGIN
  INSERT INTO incidencias_soporte(id_creador,id_responsable,id_usuario_afectado,correo,titulo,descripcion,origen,categoria,prioridad,decision,estado,numero_ticket)
  SELECT p_creador,s.id_usuario,(SELECT u.id_usuario FROM usuarios u WHERE LOWER(u.correo)=LOWER(p_correo) LIMIT 1),
         p_correo,p_titulo,p_descripcion,'EXTERNA',p_categoria,'MEDIA','PENDIENTE','PENDIENTE',CONCAT('TMP-',LEFT(REPLACE(UUID(),'-',''),26))
  FROM usuarios s WHERE s.rol='SOPORTE_TECNICO' AND s.estado='activo' ORDER BY s.id_usuario LIMIT 1;
  IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No hay personal de soporte disponible.'; END IF;
  SET p_id=LAST_INSERT_ID();
  UPDATE incidencias_soporte SET numero_ticket=CONCAT('INC-',LPAD(id_incidencia,8,'0')) WHERE id_incidencia=p_id;
  INSERT INTO notificaciones(id_usuario,tipo,titulo,mensaje)
  SELECT id_responsable,'REPORTE_SOPORTE','Nuevo reporte recibido',CONCAT('Ticket ',numero_ticket,' · Categoría: ',categoria,' · ',titulo)
  FROM incidencias_soporte WHERE id_incidencia=p_id;
END$$

CREATE PROCEDURE sp_incidencia_actualizar(IN p_actor INT,IN p_id INT,IN p_titulo VARCHAR(150),IN p_descripcion VARCHAR(4000),IN p_categoria VARCHAR(20),IN p_prioridad VARCHAR(10),IN p_decision VARCHAR(20),IN p_estado VARCHAR(20),IN p_solucion VARCHAR(4000))
BEGIN
  IF NOT EXISTS(SELECT 1 FROM incidencias_soporte WHERE id_incidencia=p_id AND id_responsable=p_actor) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Incidencia no disponible.'; END IF;
  UPDATE incidencias_soporte SET titulo=p_titulo,descripcion=p_descripcion,categoria=p_categoria,prioridad=p_prioridad,decision=p_decision,estado=p_estado,solucion=p_solucion
  WHERE id_incidencia=p_id AND id_responsable=p_actor;
END$$

CREATE PROCEDURE sp_incidencia_eliminar(IN p_actor INT,IN p_id INT)
BEGIN
  DELETE FROM incidencias_soporte WHERE id_incidencia=p_id AND id_creador=p_actor AND id_responsable=p_actor AND origen='INTERNA' AND estado='PENDIENTE' AND identidad_verificada=0;
  IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se eliminan incidencias internas propias, pendientes y sin auditoria.'; END IF;
END$$

DELIMITER ;

INSERT INTO esquema_version(version) VALUES ('2026.11.04')
ON DUPLICATE KEY UPDATE fecha_aplicacion=CURRENT_TIMESTAMP;
