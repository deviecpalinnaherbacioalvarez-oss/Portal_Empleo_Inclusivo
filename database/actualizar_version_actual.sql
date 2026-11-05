-- Actualizacion consolidada de IncluyeLab a la version 2026.10.31.
-- Conserva los datos existentes. Ejecutar con una cuenta administradora de MySQL.
-- Sustituye la ejecucion manual de las migraciones historicas 20261015-20261029.
SET NAMES utf8mb4;
USE portal_empleo_inclusivo;

-- Migra las credenciales de demostracion antiguas sin cambiar las claves conocidas.
UPDATE usuarios SET contrasena='pbkdf2$600000$2CH8nIfc/yqP+TPqd9+GoA==$OliYbqbcbro88wxaRfuVfFqF/XwSPODrm7xBQ2KJcnE=' WHERE correo='admin@incluyelab.pe' AND contrasena='123456';
UPDATE usuarios SET contrasena='pbkdf2$600000$Tspz0sAvmTpVb42Nw1G/3A==$3UYhUqsqgEcMjzgzuFQ3kmWwWtoxMGPjl3DWFXLaLQ0=' WHERE correo='empresa@incluyelab.pe' AND contrasena='Empresa#2026';
UPDATE usuarios SET contrasena='pbkdf2$600000$LF7QAuI/G8bzb/wzRwp5GQ==$8r8TXXMdU5RhQnIb8pv0vQcSh5D1jiyU6Jq67/imdpY=' WHERE correo='sofia@correo.com' AND contrasena='123456';
UPDATE usuarios SET contrasena='pbkdf2$600000$tvVso/TgcAPdQSrzgIP+IA==$lLAJTbZ1rPg9wwJQIyVUYk3opNdaltMKIhAzC6hHov4=' WHERE correo='luis@correo.com' AND contrasena='123456';
UPDATE usuarios SET contrasena='pbkdf2$600000$iykm0SperUnojw0Bb41s5Q==$mwj7n0KdxT1VD4eKbI1BXdytfawUzkm+9s3qwU7pQ88=' WHERE correo='talento@bcp.com.pe' AND contrasena='Empresa#2026';
UPDATE usuarios SET contrasena='pbkdf2$600000$koqscHv6dRkb6kv62WHimw==$g0KdR3S81Sp/Qa33A4aWZPXxfhK4RF+r1kQoUb2CVfk=' WHERE correo='empleos@interbank.pe' AND contrasena='Empresa#2026';
UPDATE usuarios SET contrasena='pbkdf2$600000$fr0IERvBvAMF9oBPhROCGA==$bnmWDzu3CU3Bst4EAlGD4lOzPSrvThDms0Bed+Dal8o=' WHERE correo='personas@alicorp.com.pe' AND contrasena='Empresa#2026';
UPDATE usuarios SET contrasena='pbkdf2$600000$LL4u/ASmDThktht39xC/Kw==$li+li+bv1qcwG/s36T2Wd4vlRwI6HGdh8jWM3/AVzP8=' WHERE correo='inclusion@rimac.com' AND contrasena='Empresa#2026';
UPDATE usuarios SET contrasena='pbkdf2$600000$+3tNEFXqHyNunQkZbgph1w==$IaOkajBx2fAmxEwr7kFSl+oaYc+N3K+ihjgkwrVM6uQ=' WHERE correo='talento@entel.pe' AND contrasena='Empresa#2026';
UPDATE usuarios SET contrasena='pbkdf2$600000$YY2n8EuhFGYZfblEdpMkQQ==$ogN5r4X68sZzNWOPD6vGpsn6vYrfQHC5kCfnwTUQYSk=' WHERE correo='empleos@sodimac.com.pe' AND contrasena='Empresa#2026';
UPDATE usuarios SET contrasena='pbkdf2$600000$8B7IQyEyTDLmKiNv0ev1hA==$BYR7sTmY7OXcRs/Lx1YofFYELHMKvsrW9zgOCT3MsEU=' WHERE correo='trabaja@inkafarma.pe' AND contrasena='Empresa#2026';
UPDATE usuarios SET contrasena='pbkdf2$600000$549MUl5NyviNeX+do7ZkGw==$ZWkEFP9XumOumH6sBfkGAtM7glaGq//eD+YcBobgEhs=' WHERE correo='talento@yape.com.pe' AND contrasena='Empresa#2026';
UPDATE empresas SET razon_social='Microsoft Peru',ruc='20254138577' WHERE ruc='00000000000' AND razon_social IN ('Microsoft','Microsoft Peru');

CREATE TABLE IF NOT EXISTS esquema_version (
    version VARCHAR(20) PRIMARY KEY,
    fecha_aplicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Usuarios, login y soporte seguro.
ALTER TABLE usuarios MODIFY nombre VARCHAR(170) NOT NULL;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='correo_verificado')=0,'ALTER TABLE usuarios ADD COLUMN correo_verificado TINYINT(1) NOT NULL DEFAULT 1','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='intentos_fallidos')=0,'ALTER TABLE usuarios ADD COLUMN intentos_fallidos TINYINT UNSIGNED NOT NULL DEFAULT 0','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='bloqueado_hasta')=0,'ALTER TABLE usuarios ADD COLUMN bloqueado_hasta DATETIME NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='requiere_cambio_clave')=0,'ALTER TABLE usuarios ADD COLUMN requiere_cambio_clave TINYINT(1) NOT NULL DEFAULT 0','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='clave_temporal_expira')=0,'ALTER TABLE usuarios ADD COLUMN clave_temporal_expira DATETIME NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='motivo_bloqueo')=0,'ALTER TABLE usuarios ADD COLUMN motivo_bloqueo VARCHAR(500) NOT NULL DEFAULT ''''','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
ALTER TABLE usuarios MODIFY rol ENUM('ADMIN','POSTULANTE','EMPRESA','RECURSOS_HUMANOS','SOPORTE_TECNICO') NOT NULL;

-- Empresa, perfil y web publica JDBC.
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='sitio_oficial')=0,'ALTER TABLE empresas ADD COLUMN sitio_oficial VARCHAR(500) NULL AFTER logo_url','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='pais')=0,'ALTER TABLE empresas ADD COLUMN pais VARCHAR(80) NOT NULL DEFAULT ''Peru'' AFTER sitio_oficial','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @faltaba_estado_revision=(SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='estado_revision')=0;
SET @ddl=IF(@faltaba_estado_revision,'ALTER TABLE empresas ADD COLUMN estado_revision ENUM(''pendiente'',''aprobada'',''rechazada'') NOT NULL DEFAULT ''pendiente''','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
UPDATE empresas SET estado_revision='aprobada' WHERE @faltaba_estado_revision=1;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='presentacion')=0,'ALTER TABLE empresas ADD COLUMN presentacion TEXT NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='anio_inicio')=0,'ALTER TABLE empresas ADD COLUMN anio_inicio INT NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='logros')=0,'ALTER TABLE empresas ADD COLUMN logros TEXT NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='motivo_revision')=0,'ALTER TABLE empresas ADD COLUMN motivo_revision VARCHAR(1000) NOT NULL DEFAULT ''''','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='version_revision')=0,'ALTER TABLE empresas ADD COLUMN version_revision INT NOT NULL DEFAULT 0','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='fecha_revision')=0,'ALTER TABLE empresas ADD COLUMN fecha_revision DATETIME NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='revisor_id')=0,'ALTER TABLE empresas ADD COLUMN revisor_id INT NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;

DROP TEMPORARY TABLE IF EXISTS tmp_directorio_empresas;
CREATE TEMPORARY TABLE tmp_directorio_empresas (razon_social VARCHAR(150) PRIMARY KEY,logo_url VARCHAR(255) NOT NULL,sitio_oficial VARCHAR(500) NOT NULL,pais VARCHAR(80) NOT NULL);
INSERT INTO tmp_directorio_empresas VALUES
('Microsoft','assets/logos/microsoft.png','https://www.microsoft.com/','Internacional'),('BCP','assets/logos/bcp.svg','https://www.viabcp.com/','Peru'),('Interbank','assets/logos/interbank.svg','https://interbank.pe/','Peru'),('Alicorp','assets/logos/alicorp.png','https://www.alicorp.com.pe/','Peru'),('Rimac Seguros','assets/logos/rimac.png','https://www.rimac.com/','Peru'),('Entel Peru','assets/logos/entel.webp','https://www.entel.pe/','Peru'),('Sodimac Peru','assets/logos/sodimac.png','https://www.sodimac.com.pe/','Peru'),('Inkafarma','assets/logos/inkafarma.png','https://inkafarma.pe/','Peru'),('Yape','assets/logos/yape.png','https://www.yape.com.pe/','Peru');
UPDATE empresas e JOIN tmp_directorio_empresas d ON d.razon_social=e.razon_social
SET e.logo_url=CASE WHEN e.logo_url IS NULL OR e.logo_url='' OR e.logo_url LIKE 'https://logo.clearbit.com/%' THEN d.logo_url ELSE e.logo_url END,
    e.sitio_oficial=COALESCE(NULLIF(e.sitio_oficial,''),d.sitio_oficial),
    e.pais=CASE WHEN e.pais='Peru' THEN d.pais ELSE e.pais END;
DROP TEMPORARY TABLE IF EXISTS tmp_directorio_empresas;

SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='ofertas' AND column_name='apoyos')=0,'ALTER TABLE ofertas ADD COLUMN apoyos VARCHAR(512) NOT NULL DEFAULT ''''','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='ofertas' AND index_name='idx_ofertas_publicas')=0,'CREATE INDEX idx_ofertas_publicas ON ofertas(estado,fecha_publicacion,id_empresa)','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;

SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='perfiles_postulantes' AND column_name='titular')=0,'ALTER TABLE perfiles_postulantes ADD COLUMN titular VARCHAR(160) NOT NULL DEFAULT '''', ADD COLUMN ubicacion VARCHAR(120) NOT NULL DEFAULT '''', ADD COLUMN acerca_de TEXT NULL, ADD COLUMN foto_url VARCHAR(255) NOT NULL DEFAULT '''', ADD COLUMN cv_nombre VARCHAR(255) NOT NULL DEFAULT '''', ADD COLUMN cv_archivo VARCHAR(255) NOT NULL DEFAULT '''', ADD COLUMN cv_actualizado DATETIME NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='perfiles_postulantes' AND column_name='id_discapacidad')=0,'ALTER TABLE perfiles_postulantes ADD COLUMN id_discapacidad TINYINT UNSIGNED NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='perfiles_postulantes' AND column_name='id_usuario' AND non_unique=0)=0,'ALTER TABLE perfiles_postulantes ADD UNIQUE KEY uq_perfil_usuario(id_usuario)','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;

CREATE TABLE IF NOT EXISTS experiencias_postulante (id_experiencia INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,cargo VARCHAR(150) NOT NULL,organizacion VARCHAR(150) NOT NULL,fecha_inicio VARCHAR(30) NOT NULL,fecha_fin VARCHAR(30) NOT NULL,descripcion VARCHAR(2000) NOT NULL DEFAULT '',FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE);
CREATE TABLE IF NOT EXISTS educacion_postulante (id_educacion INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,institucion VARCHAR(180) NOT NULL,carrera VARCHAR(180) NOT NULL,fecha_inicio VARCHAR(30) NOT NULL,fecha_fin VARCHAR(30) NOT NULL,descripcion VARCHAR(2000) NOT NULL DEFAULT '',FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE);
CREATE TABLE IF NOT EXISTS certificaciones_postulante (id_certificacion INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,nombre VARCHAR(200) NOT NULL,emisor VARCHAR(150) NOT NULL,fecha_emision VARCHAR(30) NOT NULL,credencial_url VARCHAR(500) NOT NULL DEFAULT '',FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE);

-- Mensajeria privada entre la empresa y el postulante, siempre vinculada a una postulacion existente.
CREATE TABLE IF NOT EXISTS mensajes_postulacion (
    id_mensaje BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_postulacion INT NOT NULL,
    id_remitente INT NOT NULL,
    mensaje VARCHAR(2000) NOT NULL,
    leido TINYINT(1) NOT NULL DEFAULT 0,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mensaje_postulacion FOREIGN KEY(id_postulacion) REFERENCES postulaciones(id_postulacion) ON DELETE CASCADE,
    CONSTRAINT fk_mensaje_remitente FOREIGN KEY(id_remitente) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX idx_mensaje_hilo(id_postulacion,id_mensaje),
    INDEX idx_mensaje_no_leido(id_postulacion,leido,id_remitente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Catalogo y verificacion CONADIS manual.
-- El padron local de versiones antiguas era ficticio y no representa una fuente oficial.
DROP TABLE IF EXISTS padron_conadis;
CREATE TABLE IF NOT EXISTS discapacidades (id_discapacidad TINYINT UNSIGNED NOT NULL,codigo VARCHAR(40) NOT NULL,nombre VARCHAR(180) NOT NULL,PRIMARY KEY(id_discapacidad),UNIQUE KEY uk_discapacidades_codigo(codigo),UNIQUE KEY uk_discapacidades_nombre(nombre)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT IGNORE INTO discapacidades VALUES
(1,'visual','Visual (ceguera o baja visión)'),(2,'fisica_motora','Física o motora'),(3,'auditiva','Auditiva (sordera o hipoacusia)'),(4,'intelectual','Intelectual'),(5,'habla','Dificultades del habla (afasia, disartria, etc.)'),(6,'autismo_sensorial','Autismo con necesidades sensoriales'),(7,'dislexia','Dislexia y dificultades de lectura'),(8,'movilidad_manual','Movilidad manual muy limitada'),(9,'sordoceguera','Sordoceguera'),(10,'psicosocial','Psicosocial'),(11,'tdah','TDAH con necesidades de apoyo'),(12,'cronicas_fatiga','Discapacidades asociadas a condiciones crónicas o fatiga'),(13,'fotosensibilidad','Fotosensibilidad o sensibilidad a estímulos visuales');

CREATE TABLE IF NOT EXISTS verificaciones_conadis (id_verificacion INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,rui VARCHAR(20) NULL,dni CHAR(8) NULL,apellidos VARCHAR(80) NULL,nombres VARCHAR(80) NULL,fecha_caducidad DATE NULL,id_discapacidad TINYINT UNSIGNED NULL,carnet_archivo VARCHAR(255) NOT NULL DEFAULT '',estado ENUM('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') NOT NULL DEFAULT 'PENDIENTE',metodo ENUM('MANUAL') NULL,observacion_sistema VARCHAR(1000) NOT NULL DEFAULT '',motivo VARCHAR(1000) NOT NULL DEFAULT '',id_revisor INT NULL,revision_rrhh TINYINT(1) NOT NULL DEFAULT 1,envios SMALLINT UNSIGNED NOT NULL DEFAULT 1,fecha_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,fecha_revision DATETIME NULL,UNIQUE KEY uq_verificacion_usuario(id_usuario),UNIQUE KEY uq_verificacion_rui(rui),FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,FOREIGN KEY(id_revisor) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,FOREIGN KEY(id_discapacidad) REFERENCES discapacidades(id_discapacidad));
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='consentimiento_datos_at')=0,'ALTER TABLE verificaciones_conadis ADD COLUMN consentimiento_datos_at DATETIME NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
UPDATE verificaciones_conadis SET consentimiento_datos_at=fecha_envio WHERE consentimiento_datos_at IS NULL;
ALTER TABLE verificaciones_conadis MODIFY consentimiento_datos_at DATETIME NOT NULL;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='id_discapacidad')=0,'ALTER TABLE verificaciones_conadis ADD COLUMN id_discapacidad TINYINT UNSIGNED NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='revision_rrhh')=0,'ALTER TABLE verificaciones_conadis ADD COLUMN revision_rrhh TINYINT(1) NOT NULL DEFAULT 1','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
UPDATE verificaciones_conadis
SET estado='RECHAZADA',metodo=NULL,
    motivo='Registro legado sin revision manual. Vuelve a enviar el RUI y la fotografia.',
    observacion_sistema='Requiere una nueva revision manual por Recursos Humanos.',
    id_revisor=NULL,fecha_revision=NULL
WHERE metodo='AUTOMATICA';
ALTER TABLE verificaciones_conadis MODIFY rui VARCHAR(20) NULL,MODIFY dni CHAR(8) NULL,MODIFY apellidos VARCHAR(80) NULL,MODIFY nombres VARCHAR(80) NULL,MODIFY fecha_caducidad DATE NULL,MODIFY estado ENUM('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') NOT NULL DEFAULT 'PENDIENTE',MODIFY metodo ENUM('MANUAL') NULL;
SET @ddl=IF((SELECT COUNT(*) FROM verificaciones_conadis WHERE rui IS NULL OR TRIM(rui)='')=0,'ALTER TABLE verificaciones_conadis MODIFY rui VARCHAR(20) NOT NULL','SELECT ''Revisa solicitudes sin RUI antes de endurecer la columna'''); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
ALTER TABLE verificaciones_conadis MODIFY revision_rrhh TINYINT(1) NOT NULL DEFAULT 1,MODIFY consentimiento_datos_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='rui' AND non_unique=0)=0,'ALTER TABLE verificaciones_conadis ADD UNIQUE KEY uq_verificacion_rui(rui)','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.key_column_usage WHERE table_schema=DATABASE() AND table_name='perfiles_postulantes' AND column_name='id_discapacidad' AND referenced_table_name='discapacidades')=0,'ALTER TABLE perfiles_postulantes ADD CONSTRAINT fk_perfil_discapacidad FOREIGN KEY(id_discapacidad) REFERENCES discapacidades(id_discapacidad)','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.key_column_usage WHERE table_schema=DATABASE() AND table_name='verificaciones_conadis' AND column_name='id_discapacidad' AND referenced_table_name='discapacidades')=0,'ALTER TABLE verificaciones_conadis ADD CONSTRAINT fk_verificacion_discapacidad FOREIGN KEY(id_discapacidad) REFERENCES discapacidades(id_discapacidad)','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;

CREATE TABLE IF NOT EXISTS historial_verificaciones_conadis (id_historial BIGINT AUTO_INCREMENT PRIMARY KEY,id_verificacion INT NOT NULL,id_usuario INT NOT NULL,rui VARCHAR(20) NOT NULL,carnet_archivo VARCHAR(255) NOT NULL,estado ENUM('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') NOT NULL,motivo VARCHAR(1000) NOT NULL DEFAULT '',id_revisor INT NULL,accion VARCHAR(40) NOT NULL,fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,INDEX idx_historial_verificacion_fecha(id_verificacion,fecha_evento),INDEX idx_historial_usuario_fecha(id_usuario,fecha_evento),FOREIGN KEY(id_verificacion) REFERENCES verificaciones_conadis(id_verificacion) ON DELETE RESTRICT,FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,FOREIGN KEY(id_revisor) REFERENCES usuarios(id_usuario) ON DELETE SET NULL);
INSERT INTO historial_verificaciones_conadis(id_verificacion,id_usuario,rui,carnet_archivo,estado,motivo,id_revisor,accion,fecha_evento)
SELECT v.id_verificacion,v.id_usuario,v.rui,v.carnet_archivo,v.estado,v.motivo,v.id_revisor,'MIGRACION_INICIAL',COALESCE(v.fecha_revision,v.fecha_envio,NOW())
FROM verificaciones_conadis v
WHERE v.rui IS NOT NULL AND TRIM(v.rui)<>'' AND v.carnet_archivo IS NOT NULL AND TRIM(v.carnet_archivo)<>''
  AND NOT EXISTS(SELECT 1 FROM historial_verificaciones_conadis h WHERE h.id_verificacion=v.id_verificacion);

-- Correo OTP, RRHH, incidencias, notificaciones y auditoria.
CREATE TABLE IF NOT EXISTS codigos_otp (id_otp INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,correo VARCHAR(150) NOT NULL,codigo VARCHAR(255) NOT NULL,tipo ENUM('VERIFICACION_CORREO','RECUPERACION_CLAVE','ACCESO_2FA') NOT NULL DEFAULT 'VERIFICACION_CORREO',intentos TINYINT NOT NULL DEFAULT 0,estado ENUM('PENDIENTE','VERIFICADO','EXPIRADO','BLOQUEADO') NOT NULL DEFAULT 'PENDIENTE',fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,fecha_expiracion DATETIME NOT NULL,FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE);
ALTER TABLE codigos_otp MODIFY codigo VARCHAR(255) NOT NULL;
UPDATE codigos_otp SET estado='EXPIRADO' WHERE estado='PENDIENTE' AND codigo NOT LIKE 'pbkdf2$%';
CREATE TABLE IF NOT EXISTS evaluaciones_rrhh (id_evaluacion INT AUTO_INCREMENT PRIMARY KEY,id_postulacion INT NOT NULL,id_evaluador INT NOT NULL,observaciones VARCHAR(4000) NOT NULL,retroalimentacion VARCHAR(4000) NOT NULL DEFAULT '',resultado ENUM('PENDIENTE','APROBADO','NO_APROBADO') NOT NULL DEFAULT 'PENDIENTE',estado ENUM('BORRADOR','PUBLICADO') NOT NULL DEFAULT 'BORRADOR',etapa ENUM('REVISION_CV','ENTREVISTA','DESEMPENO','FINAL') NOT NULL DEFAULT 'REVISION_CV',puntaje_cv TINYINT UNSIGNED NOT NULL DEFAULT 0,puntaje_entrevista TINYINT UNSIGNED NOT NULL DEFAULT 0,puntaje_desempeno TINYINT UNSIGNED NOT NULL DEFAULT 0,porcentaje_compatibilidad TINYINT UNSIGNED NOT NULL DEFAULT 0,fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,UNIQUE KEY uq_evaluacion_rrhh(id_postulacion,id_evaluador),FOREIGN KEY(id_postulacion) REFERENCES postulaciones(id_postulacion) ON DELETE CASCADE,FOREIGN KEY(id_evaluador) REFERENCES usuarios(id_usuario));
ALTER TABLE evaluaciones_rrhh MODIFY resultado ENUM('PENDIENTE','APROBADO','NO_APROBADO') NOT NULL DEFAULT 'PENDIENTE';
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='evaluaciones_rrhh' AND column_name='retroalimentacion')=0,'ALTER TABLE evaluaciones_rrhh ADD COLUMN retroalimentacion VARCHAR(4000) NOT NULL DEFAULT ''''','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='evaluaciones_rrhh' AND column_name='etapa')=0,'ALTER TABLE evaluaciones_rrhh ADD COLUMN etapa ENUM(''REVISION_CV'',''ENTREVISTA'',''DESEMPENO'',''FINAL'') NOT NULL DEFAULT ''REVISION_CV''','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='evaluaciones_rrhh' AND column_name='puntaje_cv')=0,'ALTER TABLE evaluaciones_rrhh ADD COLUMN puntaje_cv TINYINT UNSIGNED NOT NULL DEFAULT 0, ADD COLUMN puntaje_entrevista TINYINT UNSIGNED NOT NULL DEFAULT 0, ADD COLUMN puntaje_desempeno TINYINT UNSIGNED NOT NULL DEFAULT 0, ADD COLUMN porcentaje_compatibilidad TINYINT UNSIGNED NOT NULL DEFAULT 0','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
CREATE TABLE IF NOT EXISTS incidencias_soporte (id_incidencia INT AUTO_INCREMENT PRIMARY KEY,id_creador INT NULL,id_responsable INT NOT NULL,id_usuario_afectado INT NULL,correo VARCHAR(150) NOT NULL,titulo VARCHAR(150) NOT NULL,descripcion VARCHAR(4000) NOT NULL,origen ENUM('EXTERNA','INTERNA') NOT NULL DEFAULT 'EXTERNA',categoria ENUM('SEGURIDAD','ACCESO','INFRACCION','TECNICO','OTRO') NOT NULL DEFAULT 'TECNICO',prioridad ENUM('BAJA','MEDIA','ALTA','URGENTE') NOT NULL DEFAULT 'MEDIA',decision ENUM('PENDIENTE','ACEPTADA','RECHAZADA') NOT NULL DEFAULT 'PENDIENTE',estado ENUM('PENDIENTE','EN_PROCESO','RESUELTA') NOT NULL DEFAULT 'PENDIENTE',solucion VARCHAR(4000) NOT NULL DEFAULT '',numero_ticket VARCHAR(30) NULL,identidad_verificada TINYINT(1) NOT NULL DEFAULT 0,metodo_verificacion VARCHAR(80) NOT NULL DEFAULT '',motivo_accion VARCHAR(1000) NOT NULL DEFAULT '',fecha_verificacion DATETIME NULL,fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,FOREIGN KEY(id_creador) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,FOREIGN KEY(id_responsable) REFERENCES usuarios(id_usuario),FOREIGN KEY(id_usuario_afectado) REFERENCES usuarios(id_usuario) ON DELETE SET NULL);
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='id_usuario_afectado')=0,'ALTER TABLE incidencias_soporte ADD COLUMN id_usuario_afectado INT NULL AFTER id_responsable','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='categoria')=0,'ALTER TABLE incidencias_soporte ADD COLUMN categoria ENUM(''SEGURIDAD'',''ACCESO'',''INFRACCION'',''TECNICO'',''OTRO'') NOT NULL DEFAULT ''TECNICO'' AFTER origen','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='numero_ticket')=0,'ALTER TABLE incidencias_soporte ADD COLUMN numero_ticket VARCHAR(30) NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND column_name='identidad_verificada')=0,'ALTER TABLE incidencias_soporte ADD COLUMN identidad_verificada TINYINT(1) NOT NULL DEFAULT 0, ADD COLUMN metodo_verificacion VARCHAR(80) NOT NULL DEFAULT '''', ADD COLUMN motivo_accion VARCHAR(1000) NOT NULL DEFAULT '''', ADD COLUMN fecha_verificacion DATETIME NULL','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;
UPDATE incidencias_soporte SET numero_ticket=CONCAT('INC-',LPAD(id_incidencia,8,'0')) WHERE numero_ticket IS NULL OR numero_ticket='';
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='incidencias_soporte' AND index_name='uq_incidencia_ticket')=0,'ALTER TABLE incidencias_soporte MODIFY numero_ticket VARCHAR(30) NOT NULL, ADD UNIQUE KEY uq_incidencia_ticket(numero_ticket)','SELECT 1'); PREPARE u FROM @ddl; EXECUTE u; DEALLOCATE PREPARE u;

CREATE TABLE IF NOT EXISTS notificaciones (id_notificacion INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,tipo ENUM('POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE','CONADIS_ESTADO','CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL','CLAVE_CAMBIADA','ACTIVIDAD_SOSPECHOSA','MENSAJE_SOPORTE','NUEVO_MENSAJE') NOT NULL,titulo VARCHAR(150) NOT NULL,mensaje VARCHAR(1000) NOT NULL,leida TINYINT(1) NOT NULL DEFAULT 0,fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE);
UPDATE notificaciones SET tipo='REPORTE_SOPORTE' WHERE tipo NOT IN ('POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE','CONADIS_ESTADO','CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL','CLAVE_CAMBIADA','ACTIVIDAD_SOSPECHOSA','MENSAJE_SOPORTE');
ALTER TABLE notificaciones MODIFY tipo ENUM('POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE','CONADIS_ESTADO','CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL','CLAVE_CAMBIADA','ACTIVIDAD_SOSPECHOSA','MENSAJE_SOPORTE','NUEVO_MENSAJE') NOT NULL;
CREATE TABLE IF NOT EXISTS auditoria_soporte (id_auditoria BIGINT AUTO_INCREMENT PRIMARY KEY,id_incidencia INT NOT NULL,id_usuario_afectado INT NOT NULL,id_responsable INT NOT NULL,accion ENUM('IDENTIDAD_VERIFICADA','IDENTIDAD_RECHAZADA','CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL_GENERADA','NOTIFICACION_ENVIADA') NOT NULL,motivo VARCHAR(1000) NOT NULL,resultado ENUM('EXITO','RECHAZADO','ERROR') NOT NULL,metodo_verificacion VARCHAR(80) NOT NULL DEFAULT '',fecha_accion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(id_incidencia) REFERENCES incidencias_soporte(id_incidencia),FOREIGN KEY(id_usuario_afectado) REFERENCES usuarios(id_usuario),FOREIGN KEY(id_responsable) REFERENCES usuarios(id_usuario));

-- Reglas de auditoria CONADIS. Requieren privilegio TRIGGER.
DROP TRIGGER IF EXISTS bi_conadis_foto_rrhh;
DROP TRIGGER IF EXISTS bu_conadis_datos_rrhh;
DROP TRIGGER IF EXISTS bd_conadis_verificado_rrhh;
DROP TRIGGER IF EXISTS bi_conadis_obligatoria;
DROP TRIGGER IF EXISTS bu_conadis_obligatoria;
DROP TRIGGER IF EXISTS bd_conadis_auditada;
DELIMITER $$
CREATE TRIGGER bi_conadis_obligatoria BEFORE INSERT ON verificaciones_conadis FOR EACH ROW BEGIN IF NEW.estado<>'PENDIENTE' OR NEW.id_revisor IS NOT NULL OR NEW.rui IS NULL OR TRIM(NEW.rui)='' OR NEW.carnet_archivo IS NULL OR TRIM(NEW.carnet_archivo)='' OR NEW.consentimiento_datos_at IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La solicitud inicial requiere consentimiento, RUI, fotografia y estado PENDIENTE.'; END IF; END$$
CREATE TRIGGER bu_conadis_obligatoria BEFORE UPDATE ON verificaciones_conadis FOR EACH ROW BEGIN IF NEW.id_usuario<>OLD.id_usuario OR NEW.id_verificacion<>OLD.id_verificacion THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se puede cambiar el titular de la solicitud.'; END IF; IF NEW.estado NOT IN ('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') OR NEW.rui IS NULL OR TRIM(NEW.rui)='' OR NEW.carnet_archivo IS NULL OR TRIM(NEW.carnet_archivo)='' OR NEW.consentimiento_datos_at IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La verificacion requiere consentimiento, RUI, fotografia y estado validos.'; END IF; IF NEW.estado IN ('APROBADA','RECHAZADA','VENCIDA') AND (NEW.id_revisor IS NULL OR NOT EXISTS(SELECT 1 FROM usuarios u WHERE u.id_usuario=NEW.id_revisor AND u.rol='RECURSOS_HUMANOS' AND u.estado='activo')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La resolucion requiere un revisor de Recursos Humanos activo.'; END IF; IF NEW.estado='APROBADA' AND (NEW.metodo IS NULL OR NEW.metodo<>'MANUAL' OR NEW.dni IS NULL OR NEW.nombres IS NULL OR NEW.apellidos IS NULL OR NEW.fecha_caducidad IS NULL OR NEW.fecha_caducidad<CURDATE() OR NEW.fecha_revision IS NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La aprobacion manual requiere datos completos y vigentes.'; END IF; END$$
CREATE TRIGGER bd_conadis_auditada BEFORE DELETE ON verificaciones_conadis FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las solicitudes CONADIS auditadas no se eliminan.'; END$$
DELIMITER ;

INSERT INTO esquema_version(version) VALUES ('2026.10.31') ON DUPLICATE KEY UPDATE fecha_aplicacion=CURRENT_TIMESTAMP;
SELECT 'ACTUALIZACION_COMPLETA' AS resultado, version, fecha_aplicacion FROM esquema_version WHERE version='2026.10.31';
