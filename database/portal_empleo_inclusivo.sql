SET SQL_SAFE_UPDATES = 0;
CREATE DATABASE IF NOT EXISTS portal_empleo_inclusivo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'incluyelab_app'@'localhost' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON portal_empleo_inclusivo.* TO 'incluyelab_app'@'localhost';
FLUSH PRIVILEGES;
USE portal_empleo_inclusivo;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(170) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    contrasena VARCHAR(100) NOT NULL,
    rol ENUM('ADMIN', 'POSTULANTE', 'EMPRESA', 'RECURSOS_HUMANOS', 'SOPORTE_TECNICO') NOT NULL,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    correo_verificado TINYINT(1) NOT NULL DEFAULT 1,
    intentos_fallidos TINYINT UNSIGNED NOT NULL DEFAULT 0,
    bloqueado_hasta DATETIME NULL,
    clave_temporal_expira DATETIME NULL,
    motivo_bloqueo VARCHAR(500) NOT NULL DEFAULT '',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

SET @sql=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='correo_verificado')=0, 'ALTER TABLE usuarios ADD COLUMN correo_verificado TINYINT(1) NOT NULL DEFAULT 1', 'SELECT 1');
PREPARE seguridad_stmt FROM @sql; EXECUTE seguridad_stmt; DEALLOCATE PREPARE seguridad_stmt;
SET @sql=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='intentos_fallidos')=0, 'ALTER TABLE usuarios ADD COLUMN intentos_fallidos TINYINT UNSIGNED NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE seguridad_stmt FROM @sql; EXECUTE seguridad_stmt; DEALLOCATE PREPARE seguridad_stmt;
SET @sql=IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='usuarios' AND column_name='bloqueado_hasta')=0, 'ALTER TABLE usuarios ADD COLUMN bloqueado_hasta DATETIME NULL', 'SELECT 1');
PREPARE seguridad_stmt FROM @sql; EXECUTE seguridad_stmt; DEALLOCATE PREPARE seguridad_stmt;

CREATE TABLE IF NOT EXISTS empresas (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    ruc VARCHAR(11) NOT NULL,
    sector VARCHAR(100) NOT NULL,
    logo_url VARCHAR(255),
    sitio_oficial VARCHAR(500),
    pais VARCHAR(80) NOT NULL DEFAULT 'Peru',
    sello_inclusivo ENUM('Certificado', 'En revision', 'Pendiente') NOT NULL DEFAULT 'Pendiente',
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

SET @logo_col_exists := (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_schema = 'portal_empleo_inclusivo'
      AND table_name = 'empresas'
      AND column_name = 'logo_url'
);
SET @logo_col_sql := IF(@logo_col_exists = 0, 'ALTER TABLE empresas ADD COLUMN logo_url VARCHAR(255)', 'SELECT 1');
PREPARE logo_col_stmt FROM @logo_col_sql;
EXECUTE logo_col_stmt;
DEALLOCATE PREPARE logo_col_stmt;

CREATE TABLE IF NOT EXISTS perfiles_postulantes (
    id_perfil INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    dni VARCHAR(8),
    telefono VARCHAR(20),
    habilidades VARCHAR(255),
    tipo_discapacidad VARCHAR(120),
    id_discapacidad TINYINT UNSIGNED NULL,
    adaptacion_requerida VARCHAR(255),
    experiencia TEXT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

CREATE TABLE IF NOT EXISTS ofertas (
    id_oferta INT AUTO_INCREMENT PRIMARY KEY,
    id_empresa INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    modalidad VARCHAR(80) NOT NULL,
    ubicacion VARCHAR(120) NOT NULL,
    adaptaciones VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    salario DECIMAL(10,2) NOT NULL DEFAULT 0,
    estado ENUM('activa', 'cerrada') NOT NULL DEFAULT 'activa',
    fecha_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_empresa) REFERENCES empresas(id_empresa)
);

CREATE TABLE IF NOT EXISTS postulaciones (
    id_postulacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_oferta INT NOT NULL,
    estado ENUM('pendiente', 'en revision', 'aceptado', 'rechazado') NOT NULL DEFAULT 'pendiente',
    fecha_postulacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_oferta) REFERENCES ofertas(id_oferta)
);

INSERT IGNORE INTO usuarios(id_usuario, nombre, correo, contrasena, rol) VALUES
(1, 'Administrador Principal', 'admin@incluyelab.pe', 'pbkdf2$600000$2CH8nIfc/yqP+TPqd9+GoA==$OliYbqbcbro88wxaRfuVfFqF/XwSPODrm7xBQ2KJcnE=', 'ADMIN'),
(2, 'Microsoft (cuenta demo)', 'empresa@incluyelab.pe', 'pbkdf2$600000$Tspz0sAvmTpVb42Nw1G/3A==$3UYhUqsqgEcMjzgzuFQ3kmWwWtoxMGPjl3DWFXLaLQ0=', 'EMPRESA'),
(3, 'Sofia Ramirez', 'sofia@correo.com', 'pbkdf2$600000$LF7QAuI/G8bzb/wzRwp5GQ==$8r8TXXMdU5RhQnIb8pv0vQcSh5D1jiyU6Jq67/imdpY=', 'POSTULANTE'),
(4, 'Luis Torres', 'luis@correo.com', 'pbkdf2$600000$tvVso/TgcAPdQSrzgIP+IA==$lLAJTbZ1rPg9wwJQIyVUYk3opNdaltMKIhAzC6hHov4=', 'POSTULANTE'),
(5, 'Banco de Credito del Peru', 'talento@bcp.com.pe', 'pbkdf2$600000$iykm0SperUnojw0Bb41s5Q==$mwj7n0KdxT1VD4eKbI1BXdytfawUzkm+9s3qwU7pQ88=', 'EMPRESA'),
(6, 'Interbank', 'empleos@interbank.pe', 'pbkdf2$600000$koqscHv6dRkb6kv62WHimw==$g0KdR3S81Sp/Qa33A4aWZPXxfhK4RF+r1kQoUb2CVfk=', 'EMPRESA'),
(7, 'Alicorp', 'personas@alicorp.com.pe', 'pbkdf2$600000$fr0IERvBvAMF9oBPhROCGA==$bnmWDzu3CU3Bst4EAlGD4lOzPSrvThDms0Bed+Dal8o=', 'EMPRESA'),
(8, 'Rimac Seguros', 'inclusion@rimac.com', 'pbkdf2$600000$LL4u/ASmDThktht39xC/Kw==$li+li+bv1qcwG/s36T2Wd4vlRwI6HGdh8jWM3/AVzP8=', 'EMPRESA'),
(9, 'Entel Peru', 'talento@entel.pe', 'pbkdf2$600000$+3tNEFXqHyNunQkZbgph1w==$IaOkajBx2fAmxEwr7kFSl+oaYc+N3K+ihjgkwrVM6uQ=', 'EMPRESA'),
(10, 'Sodimac Peru', 'empleos@sodimac.com.pe', 'pbkdf2$600000$YY2n8EuhFGYZfblEdpMkQQ==$ogN5r4X68sZzNWOPD6vGpsn6vYrfQHC5kCfnwTUQYSk=', 'EMPRESA'),
(11, 'Inkafarma', 'trabaja@inkafarma.pe', 'pbkdf2$600000$8B7IQyEyTDLmKiNv0ev1hA==$BYR7sTmY7OXcRs/Lx1YofFYELHMKvsrW9zgOCT3MsEU=', 'EMPRESA'),
(12, 'Yape', 'talento@yape.com.pe', 'pbkdf2$600000$549MUl5NyviNeX+do7ZkGw==$ZWkEFP9XumOumH6sBfkGAtM7glaGq//eD+YcBobgEhs=', 'EMPRESA');

INSERT IGNORE INTO empresas(id_empresa, id_usuario, razon_social, ruc, sector, logo_url, sello_inclusivo) VALUES
(1, 2, 'Microsoft Peru', '20254138577', 'Tecnologia', 'assets/logos/microsoft.png', 'Pendiente'),
(2, 5, 'BCP', '20100047218', 'Banca', 'https://logo.clearbit.com/bcp.com.pe', 'Certificado'),
(3, 6, 'Interbank', '20100053455', 'Banca', 'https://logo.clearbit.com/interbank.pe', 'Certificado'),
(4, 7, 'Alicorp', '20100055237', 'Consumo masivo', 'https://logo.clearbit.com/alicorp.com.pe', 'En revision'),
(5, 8, 'Rimac Seguros', '20100041953', 'Seguros', 'https://logo.clearbit.com/rimac.com', 'Certificado'),
(6, 9, 'Entel Peru', '20543254798', 'Telecomunicaciones', 'https://logo.clearbit.com/entel.pe', 'En revision'),
(7, 10, 'Sodimac Peru', '20389230724', 'Retail', 'https://logo.clearbit.com/sodimac.com.pe', 'Certificado'),
(8, 11, 'Inkafarma', '20100028698', 'Salud y retail', 'https://logo.clearbit.com/inkafarma.pe', 'Certificado'),
(9, 12, 'Yape', '20538888029', 'Fintech', 'https://logo.clearbit.com/yape.com.pe', 'Certificado');

UPDATE empresas SET logo_url='https://logo.clearbit.com/bcp.com.pe' WHERE razon_social='BCP' AND (logo_url IS NULL OR logo_url='');
UPDATE empresas SET logo_url='https://logo.clearbit.com/interbank.pe' WHERE razon_social='Interbank' AND (logo_url IS NULL OR logo_url='');
UPDATE empresas SET logo_url='https://logo.clearbit.com/alicorp.com.pe' WHERE razon_social='Alicorp' AND (logo_url IS NULL OR logo_url='');
UPDATE empresas SET logo_url='https://logo.clearbit.com/rimac.com' WHERE razon_social='Rimac Seguros' AND (logo_url IS NULL OR logo_url='');
UPDATE empresas SET logo_url=CASE razon_social WHEN 'Microsoft Peru' THEN 'assets/logos/microsoft.png' WHEN 'BCP' THEN 'assets/logos/bcp.svg' WHEN 'Interbank' THEN 'assets/logos/interbank.svg' WHEN 'Alicorp' THEN 'assets/logos/alicorp.png' WHEN 'Rimac Seguros' THEN 'assets/logos/rimac.png' WHEN 'Entel Peru' THEN 'assets/logos/entel.webp' WHEN 'Sodimac Peru' THEN 'assets/logos/sodimac.png' WHEN 'Inkafarma' THEN 'assets/logos/inkafarma.png' WHEN 'Yape' THEN 'assets/logos/yape.png' ELSE logo_url END, sitio_oficial=CASE razon_social WHEN 'Microsoft Peru' THEN 'https://www.microsoft.com/es-pe/' WHEN 'BCP' THEN 'https://www.viabcp.com/' WHEN 'Interbank' THEN 'https://interbank.pe/' WHEN 'Alicorp' THEN 'https://www.alicorp.com.pe/' WHEN 'Rimac Seguros' THEN 'https://www.rimac.com/' WHEN 'Entel Peru' THEN 'https://www.entel.pe/' WHEN 'Sodimac Peru' THEN 'https://www.sodimac.com.pe/' WHEN 'Inkafarma' THEN 'https://inkafarma.pe/' WHEN 'Yape' THEN 'https://www.yape.com.pe/' ELSE sitio_oficial END, pais=CASE WHEN razon_social='Microsoft Peru' THEN 'Peru' ELSE pais END WHERE razon_social IN ('Microsoft Peru','BCP','Interbank','Alicorp','Rimac Seguros','Entel Peru','Sodimac Peru','Inkafarma','Yape');

INSERT IGNORE INTO perfiles_postulantes(id_perfil, id_usuario, dni, telefono, habilidades, tipo_discapacidad, adaptacion_requerida, experiencia) VALUES
(1, 3, '70568033', '999111222', 'Atencion al cliente, Excel, soporte remoto', '', 'Acceso con rampa y horario flexible', 'Experiencia en soporte administrativo.'),
(2, 4, '45687643', '988777666', 'Diseno grafico, redes sociales, redaccion', '', 'Compatibilidad con lector de pantalla', 'Practicas en comunicacion digital.');

INSERT IGNORE INTO ofertas(id_oferta, id_empresa, titulo, modalidad, ubicacion, adaptaciones, descripcion, salario) VALUES
(1, 1, 'Asistente de soporte remoto', 'Remoto', 'Lima', 'Horario flexible, lector de pantalla, reuniones grabadas', '## Acerca del empleo\nMicrosoft busca una persona orientada al servicio para brindar soporte remoto accesible.\n## Funciones principales\n- Atender solicitudes mediante la mesa de ayuda.\n- Diagnosticar problemas de Windows, Microsoft 365 y conectividad.\n- Documentar soluciones y escalar incidentes complejos.\n## Formación\nEstudios técnicos o universitarios en Sistemas, Informática o Redes.\n## Experiencia\nSeis meses en soporte técnico o atención de incidencias.\n## Conocimientos técnicos\n- Windows 10 y 11, Microsoft 365 y configuración de periféricos.\n- Redes, acceso remoto y seguridad digital básica.\n## Condiciones laborales\n- Modalidad remota desde Lima.\n- Jornada de lunes a viernes con horario flexible.', 1800.00),
(2, 1, 'Auxiliar administrativo inclusivo', 'Presencial accesible', 'San Juan de Lurigancho', 'Rampa, ascensor, escritorio ergonomico', '## Acerca del empleo\nApoyo administrativo para organizar documentación y solicitudes internas.\n## Funciones principales\n- Registrar, digitalizar y archivar documentos.\n- Actualizar bases de datos y reportes sencillos.\n- Coordinar reuniones y consultas internas.\n## Formación\nEstudios en Administración, Contabilidad o Gestión Documental.\n## Experiencia\nSeis meses en labores administrativas o archivo.\n## Conocimientos técnicos\n- Word, Excel y correo electrónico.\n- Organización de archivos físicos y digitales.\n## Condiciones laborales\n- Presencial en San Juan de Lurigancho.\n- Rampa, ascensor y escritorio ergonómico.', 1500.00),
(3, 1, 'Analista junior de datos', 'Hibrido', 'Lima Centro', 'Capacitacion inicial, mentor asignado, herramientas accesibles', '## Acerca del empleo\nTransformar información operativa en reportes útiles para la toma de decisiones.\n## Funciones principales\n- Limpiar y validar bases de datos.\n- Elaborar reportes, tableros e indicadores.\n- Documentar fuentes y reglas del análisis.\n## Formación\nSistemas, Estadística, Ingeniería Industrial, Economía o afines.\n## Experiencia\nUn año en análisis de datos o reportería.\n## Conocimientos técnicos\n- Excel, SQL y Power BI.\n- Calidad y protección de datos.\n## Condiciones laborales\n- Modalidad híbrida en Lima Centro.\n- Mentor y herramientas accesibles.', 2200.00),
(4, 2, 'Asistente de experiencia al cliente inclusivo', 'Hibrido', 'Lima, Peru', 'Lector de pantalla, horario flexible, reuniones con subtitulos', '## Acerca del empleo\nBCP busca acompañar a clientes por canales digitales accesibles.\n## Funciones principales\n- Atender consultas por chat, correo y teléfono.\n- Orientar sobre productos y operaciones seguras.\n- Registrar y seguir solicitudes hasta su solución.\n## Formación\nAdministración, Comunicaciones, Marketing, Banca o afines.\n## Experiencia\nUn año en atención al cliente o canales digitales.\n## Conocimientos técnicos\n- CRM, Microsoft Office y protección de datos.\n## Condiciones laborales\n- Modalidad híbrida en Lima.\n- Lector de pantalla, subtítulos y flexibilidad coordinada.', 2400.00),
(5, 3, 'Practicante de tecnologia accesible', 'Hibrido', 'San Isidro, Lima', 'Mentor asignado, laptop adaptada, espacios sin barreras', '## Acerca del empleo\nPráctica para participar en tecnología y accesibilidad digital.\n## Funciones principales\n- Ejecutar pruebas funcionales y de accesibilidad.\n- Registrar incidencias con pasos y evidencias.\n- Apoyar en documentación y seguimiento de mejoras.\n## Formación\nEstudiante desde sexto ciclo de Sistemas, Software o Informática.\n## Experiencia\nNo se requiere experiencia; se valoran proyectos académicos.\n## Conocimientos técnicos\n- HTML, CSS, JavaScript y pruebas de software.\n- Accesibilidad WCAG y Git básico.\n## Condiciones laborales\n- Práctica híbrida en San Isidro.\n- Laptop adaptada y mentor asignado.', 1800.00),
(6, 4, 'Analista de datos junior', 'Remoto', 'Peru', 'Trabajo remoto, comunicacion escrita, pausas sensoriales', '## Acerca del empleo\nAlicorp busca analizar información comercial y operativa.\n## Funciones principales\n- Consolidar información de ventas.\n- Elaborar tableros y reportes automáticos.\n- Verificar datos y comunicar hallazgos.\n## Formación\nEstadística, Sistemas, Ingeniería Industrial, Economía o afines.\n## Experiencia\nUn año en análisis o inteligencia de negocios.\n## Conocimientos técnicos\n- SQL, Excel avanzado y Power BI.\n- Deseable Python.\n## Condiciones laborales\n- Trabajo remoto desde Perú.\n- Pausas coordinadas y comunicación escrita.', 2600.00),
(7, 5, 'Ejecutivo de soporte administrativo', 'Presencial accesible', 'Miraflores, Lima', 'Ascensor, rutas accesibles, interprete LS previa coordinacion', '## Acerca del empleo\nRímac requiere soporte para expedientes y solicitudes internas.\n## Funciones principales\n- Revisar, registrar y archivar documentación.\n- Actualizar estados de solicitudes.\n- Coordinar atenciones y reportes de seguimiento.\n## Formación\nAdministración, Seguros, Contabilidad o afines.\n## Experiencia\nUn año en gestión documental u operaciones.\n## Conocimientos técnicos\n- Excel, Microsoft 365 y sistemas de gestión.\n## Condiciones laborales\n- Presencial en Miraflores, de lunes a viernes.\n- Ascensor, rutas accesibles e intérprete de LSP coordinado.', 2300.00),
(8, 6, 'Asesor de atencion digital', 'Remoto', 'Lima y provincias', 'Software lector, capacitacion inclusiva, horario flexible', '## Acerca del empleo\nEntel busca resolver consultas mediante canales digitales accesibles.\n## Funciones principales\n- Atender por chat, correo y redes sociales.\n- Resolver consultas de servicios y facturación.\n- Registrar y escalar incidencias técnicas.\n## Formación\nComunicaciones, Administración, Sistemas o afines.\n## Experiencia\nSeis meses en atención, soporte o contact center.\n## Conocimientos técnicos\n- CRM, ofimática y comunicación digital.\n- Telefonía móvil e internet básico.\n## Condiciones laborales\n- Remoto para Lima y provincias.\n- Horarios rotativos, pausas activas y software lector.', 1900.00),
(9, 7, 'Auxiliar de tienda con accesibilidad', 'Presencial accesible', 'Ate, Lima', 'Rampas, senalizacion clara, acompanamiento inicial', '## Acerca del empleo\nSodimac incorpora apoyo para la operación de tienda y orientación al cliente.\n## Funciones principales\n- Reponer y ordenar mercadería liviana.\n- Verificar precios y disponibilidad.\n- Orientar a clientes y mantener rutas seguras.\n## Formación\nSecundaria completa; se valoran estudios técnicos.\n## Experiencia\nNo indispensable; se valora tienda, almacén o atención.\n## Conocimientos técnicos\n- Atención al cliente e inventario básico.\n## Condiciones laborales\n- Presencial en Ate con turnos rotativos.\n- Rampas, señalización y acompañamiento inicial.', 1600.00),
(10, 8, 'Asistente de operaciones farmaceuticas', 'Hibrido', 'Lima Norte', 'Entorno guiado, capacitacion por pasos, comunicacion visual', '## Acerca del empleo\nInkafarma busca apoyo para información operativa de establecimientos.\n## Funciones principales\n- Actualizar controles de inventario y operación.\n- Registrar incidencias y dar seguimiento.\n- Preparar reportes y validar documentos.\n## Formación\nAdministración, Farmacia, Ingeniería Industrial o afines.\n## Experiencia\nSeis meses en operaciones, inventarios o soporte.\n## Conocimientos técnicos\n- Excel y sistemas de registro.\n- Inventario, trazabilidad y organización documental.\n## Condiciones laborales\n- Modalidad híbrida en Lima Norte.\n- Capacitación paso a paso y comunicación visual.', 1700.00),
(11, 9, 'Analista junior de producto digital', 'Hibrido', 'La Molina, Lima', 'Subtitulos, lector de pantalla, reuniones grabadas', '## Acerca del empleo\nYape busca apoyar la evolución de productos digitales y la experiencia de usuario.\n## Funciones principales\n- Seguir el backlog y entregables del producto.\n- Analizar indicadores y preparar reportes.\n- Ejecutar pruebas y documentar resultados.\n## Formación\nSistemas, Ingeniería Industrial, Administración, Diseño o afines.\n## Experiencia\nUn año en producto digital, proyectos o experiencia de usuario.\n## Conocimientos técnicos\n- Metodologías ágiles, Jira y SQL básico.\n- Analítica digital y pruebas funcionales.\n## Condiciones laborales\n- Modalidad híbrida en La Molina.\n- Subtítulos, grabaciones y lector de pantalla.', 2800.00);

INSERT IGNORE INTO postulaciones(id_postulacion, id_usuario, id_oferta, estado) VALUES
(1, 3, 1, 'pendiente'),
(2, 4, 3, 'en revision');

-- Non-destructive migration: explicit support declarations for phase 1.
USE portal_empleo_inclusivo;
SET @existe_apoyos = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema=DATABASE() AND table_name='ofertas' AND column_name='apoyos');
SET @sql_apoyos = IF(@existe_apoyos=0,
    'ALTER TABLE ofertas ADD COLUMN apoyos VARCHAR(512) NOT NULL DEFAULT ''''',
    'SELECT 1');
PREPARE stmt_apoyos FROM @sql_apoyos;
EXECUTE stmt_apoyos;
DEALLOCATE PREPARE stmt_apoyos;

-- Only annotate the original demonstration text, not arbitrary offers.
-- Exact matches avoid inventing support for user-authored or edited content.
UPDATE ofertas SET apoyos=CASE adaptaciones
    WHEN 'Horario flexible, lector de pantalla, reuniones grabadas' THEN 'lector,flexible'
    WHEN 'Rampa, ascensor, escritorio ergonomico' THEN 'rampas,ascensores'
    WHEN 'Lector de pantalla, horario flexible, reuniones con subtitulos' THEN 'lector,subtitulos,flexible'
    WHEN 'Trabajo remoto, comunicacion escrita, pausas sensoriales' THEN 'escrita'
    WHEN 'Ascensor, rutas accesibles, interprete LS previa coordinacion' THEN 'ascensores'
    WHEN 'Software lector, capacitacion inclusiva, horario flexible' THEN 'lector,flexible'
    WHEN 'Rampas, senalizacion clara, acompanamiento inicial' THEN 'rampas'
    WHEN 'Subtitulos, lector de pantalla, reuniones grabadas' THEN 'lector,subtitulos'
    ELSE apoyos END
WHERE apoyos='' AND @existe_apoyos=0;

-- Non-destructive and repeatable. Existing demo records retain visibility.
USE portal_empleo_inclusivo;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='estado_revision');
SET @ddl=IF(@missing, 'ALTER TABLE empresas ADD COLUMN estado_revision ENUM(''pendiente'',''aprobada'',''rechazada'') NOT NULL DEFAULT ''pendiente''', 'SELECT 1');
PREPARE migration FROM @ddl;
EXECUTE migration;
DEALLOCATE PREPARE migration;

-- Perfil profesional y seguimiento de postulaciones (2026-10-18).
SET @sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='perfiles_postulantes' AND column_name='titular')=0,
 'ALTER TABLE perfiles_postulantes ADD COLUMN titular VARCHAR(160) NOT NULL DEFAULT '''', ADD COLUMN ubicacion VARCHAR(120) NOT NULL DEFAULT '''', ADD COLUMN acerca_de TEXT NULL, ADD COLUMN foto_url VARCHAR(255) NOT NULL DEFAULT '''', ADD COLUMN cv_nombre VARCHAR(255) NOT NULL DEFAULT '''', ADD COLUMN cv_archivo VARCHAR(255) NOT NULL DEFAULT '''', ADD COLUMN cv_actualizado DATETIME NULL', 'SELECT 1');
PREPARE perfil_stmt FROM @sql; EXECUTE perfil_stmt; DEALLOCATE PREPARE perfil_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='perfiles_postulantes' AND index_name='uq_perfil_usuario')=0, 'ALTER TABLE perfiles_postulantes ADD UNIQUE KEY uq_perfil_usuario(id_usuario)', 'SELECT 1');
PREPARE perfil_stmt FROM @sql; EXECUTE perfil_stmt; DEALLOCATE PREPARE perfil_stmt;
CREATE TABLE IF NOT EXISTS experiencias_postulante (id_experiencia INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,cargo VARCHAR(150) NOT NULL,organizacion VARCHAR(150) NOT NULL,fecha_inicio VARCHAR(30) NOT NULL,fecha_fin VARCHAR(30) NOT NULL,descripcion VARCHAR(2000) NOT NULL DEFAULT '',FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE);
CREATE TABLE IF NOT EXISTS educacion_postulante (id_educacion INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,institucion VARCHAR(180) NOT NULL,carrera VARCHAR(180) NOT NULL,fecha_inicio VARCHAR(30) NOT NULL,fecha_fin VARCHAR(30) NOT NULL,descripcion VARCHAR(2000) NOT NULL DEFAULT '',FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE);
CREATE TABLE IF NOT EXISTS certificaciones_postulante (id_certificacion INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,nombre VARCHAR(200) NOT NULL,emisor VARCHAR(150) NOT NULL,fecha_emision VARCHAR(30) NOT NULL,credencial_url VARCHAR(500) NOT NULL DEFAULT '',FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE);
SET @sofia=(SELECT id_usuario FROM usuarios WHERE correo='sofia@correo.com' AND rol='POSTULANTE' LIMIT 1);
INSERT INTO perfiles_postulantes(id_usuario,telefono,habilidades,adaptacion_requerida,titular,ubicacion,acerca_de,foto_url) SELECT @sofia,'999111222','Java, MySQL, HTML, CSS, Bootstrap, soporte TI, trabajo en equipo','Indicaciones escritas, herramientas compatibles con lector de pantalla y modalidad híbrida','Estudiante de Ingeniería de Sistemas | Java, MySQL y soporte TI','San Juan de Lurigancho, Lima','Perfil de demostración. Estudiante de Ingeniería de Sistemas interesada en desarrollo web, bases de datos y soporte tecnológico. Me motiva crear soluciones digitales accesibles, documentar procesos con claridad y colaborar en equipos diversos. Busco una oportunidad preprofesional para seguir aprendiendo y aportar con responsabilidad.','asset:perfil-sofia-demo.png' WHERE @sofia IS NOT NULL ON DUPLICATE KEY UPDATE telefono=VALUES(telefono),habilidades=VALUES(habilidades),adaptacion_requerida=VALUES(adaptacion_requerida),titular=VALUES(titular),ubicacion=VALUES(ubicacion),acerca_de=VALUES(acerca_de),foto_url=VALUES(foto_url);
INSERT INTO experiencias_postulante(id_usuario,cargo,organizacion,fecha_inicio,fecha_fin,descripcion) SELECT @sofia,'Practicante de soporte y desarrollo web','Proyecto académico IncluyeLab','Abr. 2025','Dic. 2025','Experiencia ficticia de demostración: apoyo en pruebas funcionales, documentación de incidencias y construcción de interfaces accesibles con Java, JSP, Bootstrap y MySQL.' WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM experiencias_postulante WHERE id_usuario=@sofia AND organizacion='Proyecto académico IncluyeLab');
INSERT INTO educacion_postulante(id_usuario,institucion,carrera,fecha_inicio,fecha_fin,descripcion) SELECT @sofia,'Universidad Privada del Norte','Ingeniería de Sistemas Computacionales','Mar. 2023','Actualidad','Formación ficticia de demostración enfocada en programación, bases de datos, análisis de sistemas y desarrollo de aplicaciones web.' WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM educacion_postulante WHERE id_usuario=@sofia AND institucion='Universidad Privada del Norte');
INSERT INTO certificaciones_postulante(id_usuario,nombre,emisor,fecha_emision,credencial_url) SELECT @sofia,'Fundamentos de bases de datos','Programa académico de demostración','Ago. 2026','' WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM certificaciones_postulante WHERE id_usuario=@sofia AND nombre='Fundamentos de bases de datos');
INSERT INTO certificaciones_postulante(id_usuario,nombre,emisor,fecha_emision,credencial_url) SELECT @sofia,'Introducción a la accesibilidad web','IncluyeLab - contenido demostrativo','Sep. 2026','' WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM certificaciones_postulante WHERE id_usuario=@sofia AND nombre='Introducción a la accesibilidad web');
UPDATE empresas SET estado_revision='aprobada' WHERE @missing=1;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='presentacion');
SET @ddl=IF(@missing, 'ALTER TABLE empresas ADD COLUMN presentacion TEXT NULL', 'SELECT 1');
PREPARE migration FROM @ddl;
EXECUTE migration;
DEALLOCATE PREPARE migration;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='anio_inicio');
SET @ddl=IF(@missing, 'ALTER TABLE empresas ADD COLUMN anio_inicio INT NULL', 'SELECT 1');
PREPARE migration FROM @ddl;
EXECUTE migration;
DEALLOCATE PREPARE migration;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='logros');
SET @ddl=IF(@missing, 'ALTER TABLE empresas ADD COLUMN logros TEXT NULL', 'SELECT 1');
PREPARE migration FROM @ddl;
EXECUTE migration;
DEALLOCATE PREPARE migration;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='motivo_revision');
SET @ddl=IF(@missing, 'ALTER TABLE empresas ADD COLUMN motivo_revision VARCHAR(1000) NOT NULL DEFAULT ''''', 'SELECT 1');
PREPARE migration FROM @ddl;
EXECUTE migration;
DEALLOCATE PREPARE migration;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='version_revision');
SET @ddl=IF(@missing, 'ALTER TABLE empresas ADD COLUMN version_revision INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE migration FROM @ddl;
EXECUTE migration;
DEALLOCATE PREPARE migration;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='fecha_revision');
SET @ddl=IF(@missing, 'ALTER TABLE empresas ADD COLUMN fecha_revision DATETIME NULL', 'SELECT 1');
PREPARE migration FROM @ddl;
EXECUTE migration;
DEALLOCATE PREPARE migration;
SET @missing=(SELECT COUNT(*)=0 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='empresas' AND column_name='revisor_id');
SET @ddl=IF(@missing, 'ALTER TABLE empresas ADD COLUMN revisor_id INT NULL', 'SELECT 1');
PREPARE migration FROM @ddl;
EXECUTE migration;
DEALLOCATE PREPARE migration;

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
    numero_ticket VARCHAR(30) NULL,
    identidad_verificada TINYINT(1) NOT NULL DEFAULT 0,
    metodo_verificacion VARCHAR(80) NOT NULL DEFAULT '',
    motivo_accion VARCHAR(1000) NOT NULL DEFAULT '',
    fecha_verificacion DATETIME NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_incidencia_creador FOREIGN KEY (id_creador)
        REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT fk_incidencia_responsable FOREIGN KEY (id_responsable)
        REFERENCES usuarios(id_usuario)
);

CREATE TABLE IF NOT EXISTS notificaciones (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo ENUM('POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE','CONADIS_ESTADO','CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL','CLAVE_CAMBIADA','ACTIVIDAD_SOSPECHOSA','MENSAJE_SOPORTE') NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    mensaje VARCHAR(1000) NOT NULL,
    leida TINYINT(1) NOT NULL DEFAULT 0,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notificacion_usuario FOREIGN KEY(id_usuario)
        REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX idx_notificacion_usuario_fecha(id_usuario,fecha_creacion)
);

INSERT INTO usuarios(nombre,correo,contrasena,rol,estado)
VALUES ('Daniel Angel Advincula Miraval','daniel.advincula@incluyelab.com',
'pbkdf2$600000$M27ETomKEgpzEHzCwgWBIA==$6cu5f2NyPXGXO8dNvglqONdEEhgjzjPpobS3y8if0f4=',
'SOPORTE_TECNICO','activo')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre),rol=VALUES(rol),estado='activo';

-- Ampliacion de Recursos Humanos, recuperacion de cuentas y seguridad.
ALTER TABLE evaluaciones_rrhh
    MODIFY resultado ENUM('PENDIENTE','APROBADO','NO_APROBADO') NOT NULL DEFAULT 'PENDIENTE',
    ADD COLUMN puntaje_cv TINYINT UNSIGNED NOT NULL DEFAULT 0,
    ADD COLUMN puntaje_entrevista TINYINT UNSIGNED NOT NULL DEFAULT 0,
    ADD COLUMN puntaje_desempeno TINYINT UNSIGNED NOT NULL DEFAULT 0,
    ADD COLUMN porcentaje_compatibilidad TINYINT UNSIGNED NOT NULL DEFAULT 0,
    ADD COLUMN etapa ENUM('REVISION_CV','ENTREVISTA','DESEMPENO','FINAL') NOT NULL DEFAULT 'REVISION_CV',
    ADD COLUMN retroalimentacion VARCHAR(4000) NOT NULL DEFAULT '';

ALTER TABLE usuarios ADD COLUMN requiere_cambio_clave TINYINT(1) NOT NULL DEFAULT 0;

ALTER TABLE incidencias_soporte
    ADD COLUMN id_usuario_afectado INT NULL AFTER id_responsable,
    ADD COLUMN categoria ENUM('SEGURIDAD','ACCESO','INFRACCION','TECNICO','OTRO') NOT NULL DEFAULT 'TECNICO' AFTER origen,
    ADD CONSTRAINT fk_incidencia_usuario_afectado FOREIGN KEY(id_usuario_afectado)
        REFERENCES usuarios(id_usuario) ON DELETE SET NULL;

INSERT INTO usuarios(nombre,correo,contrasena,rol,estado)
VALUES ('Marco Polo Salcedo Castillo','marco.salcedo@incluyelab.com',
'pbkdf2$600000$YEughiPdU0O7j8BhfRexiA==$dFI0SjRyPsRtdHoHhA9cphzKqM9GJGySANkRaFYcI7U=',
'RECURSOS_HUMANOS','activo')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre),rol=VALUES(rol),estado='activo';


-- Flujo de Verificacion de Identidad Digital: carnet CONADIS (2026-10-23).
-- No destructiva y repetible. Solo aplica a cuentas con rol POSTULANTE.
USE portal_empleo_inclusivo;

-- La revision es manual por RRHH. No se simula un padron ni una consulta oficial.
CREATE TABLE IF NOT EXISTS verificaciones_conadis (
    id_verificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    rui VARCHAR(20) NOT NULL,
    dni CHAR(8) NULL,
    apellidos VARCHAR(80) NULL,
    nombres VARCHAR(80) NULL,
    fecha_caducidad DATE NULL,
    id_discapacidad TINYINT UNSIGNED NULL,
    carnet_archivo VARCHAR(255) NOT NULL DEFAULT '',
    estado ENUM('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') NOT NULL DEFAULT 'PENDIENTE',
    metodo ENUM('MANUAL') NULL,
    observacion_sistema VARCHAR(1000) NOT NULL DEFAULT '',
    motivo VARCHAR(1000) NOT NULL DEFAULT '',
    id_revisor INT NULL,
    revision_rrhh BOOLEAN NOT NULL DEFAULT TRUE,
    envios SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    fecha_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_revision DATETIME NULL,
    consentimiento_datos_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_verificacion_usuario(id_usuario),
    INDEX idx_verificacion_estado(estado,fecha_envio),
    UNIQUE KEY uq_verificacion_rui(rui),
    INDEX idx_verificacion_dni(dni),
    CONSTRAINT fk_verificacion_usuario FOREIGN KEY(id_usuario)
        REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_verificacion_revisor FOREIGN KEY(id_revisor)
        REFERENCES usuarios(id_usuario) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS historial_verificaciones_conadis (
    id_historial BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_verificacion INT NOT NULL,
    id_usuario INT NOT NULL,
    rui VARCHAR(20) NOT NULL,
    carnet_archivo VARCHAR(255) NOT NULL,
    estado ENUM('PENDIENTE','APROBADA','RECHAZADA','VENCIDA') NOT NULL,
    motivo VARCHAR(1000) NOT NULL DEFAULT '',
    id_revisor INT NULL,
    accion VARCHAR(40) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_historial_verificacion_fecha(id_verificacion,fecha_evento),
    CONSTRAINT fk_historial_verificacion FOREIGN KEY(id_verificacion) REFERENCES verificaciones_conadis(id_verificacion) ON DELETE RESTRICT,
    CONSTRAINT fk_historial_usuario FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,
    CONSTRAINT fk_historial_revisor FOREIGN KEY(id_revisor) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
);

-- Tabla para Códigos OTP de Verificación de Correo y 2FA
CREATE TABLE IF NOT EXISTS codigos_otp (
    id_otp INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    correo VARCHAR(150) NOT NULL,
    codigo VARCHAR(255) NOT NULL,
    tipo ENUM('VERIFICACION_CORREO', 'RECUPERACION_CLAVE', 'ACCESO_2FA') NOT NULL DEFAULT 'VERIFICACION_CORREO',
    intentos TINYINT NOT NULL DEFAULT 0,
    estado ENUM('PENDIENTE', 'VERIFICADO', 'EXPIRADO', 'BLOQUEADO') NOT NULL DEFAULT 'PENDIENTE',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion DATETIME NOT NULL,
    CONSTRAINT fk_otp_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX idx_otp_usuario_tipo (id_usuario, tipo, estado),
    INDEX idx_otp_correo (correo, estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Migración 20261027: catálogo de discapacidades y necesidades
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

-- Parte 5: seguridad y auditoria de Soporte Tecnico.
UPDATE incidencias_soporte SET numero_ticket=CONCAT('INC-',LPAD(id_incidencia,8,'0')) WHERE numero_ticket IS NULL OR numero_ticket='';
ALTER TABLE incidencias_soporte MODIFY numero_ticket VARCHAR(30) NOT NULL, ADD UNIQUE KEY uq_incidencia_ticket(numero_ticket);
CREATE TABLE IF NOT EXISTS auditoria_soporte (
    id_auditoria BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_incidencia INT NOT NULL,
    id_usuario_afectado INT NOT NULL,
    id_responsable INT NOT NULL,
    accion ENUM('IDENTIDAD_VERIFICADA','IDENTIDAD_RECHAZADA','CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL_GENERADA','NOTIFICACION_ENVIADA') NOT NULL,
    motivo VARCHAR(1000) NOT NULL,
    resultado ENUM('EXITO','RECHAZADO','ERROR') NOT NULL,
    metodo_verificacion VARCHAR(80) NOT NULL DEFAULT '',
    fecha_accion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auditoria_soporte_incidencia FOREIGN KEY(id_incidencia) REFERENCES incidencias_soporte(id_incidencia),
    CONSTRAINT fk_auditoria_soporte_afectado FOREIGN KEY(id_usuario_afectado) REFERENCES usuarios(id_usuario),
    CONSTRAINT fk_auditoria_soporte_responsable FOREIGN KEY(id_responsable) REFERENCES usuarios(id_usuario),
    INDEX idx_auditoria_soporte_responsable_fecha(id_responsable,fecha_accion),
    INDEX idx_auditoria_soporte_afectado_fecha(id_usuario_afectado,fecha_accion)
);

-- Finalizacion de la instalacion consolidada (2026-10-31).
-- Esta seccion alinea el instalador nuevo con las Partes 3, 5 y 6.
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='ofertas' AND index_name='idx_ofertas_publicas')=0,
 'CREATE INDEX idx_ofertas_publicas ON ofertas(estado,fecha_publicacion,id_empresa)', 'SELECT 1');
PREPARE final_stmt FROM @ddl; EXECUTE final_stmt; DEALLOCATE PREPARE final_stmt;

SET @ddl=IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='perfiles_postulantes' AND constraint_name='fk_perfil_discapacidad')=0,
 'ALTER TABLE perfiles_postulantes ADD CONSTRAINT fk_perfil_discapacidad FOREIGN KEY(id_discapacidad) REFERENCES discapacidades(id_discapacidad)', 'SELECT 1');
PREPARE final_stmt FROM @ddl; EXECUTE final_stmt; DEALLOCATE PREPARE final_stmt;
SET @ddl=IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='verificaciones_conadis' AND constraint_name='fk_verificacion_discapacidad')=0,
 'ALTER TABLE verificaciones_conadis ADD CONSTRAINT fk_verificacion_discapacidad FOREIGN KEY(id_discapacidad) REFERENCES discapacidades(id_discapacidad)', 'SELECT 1');
PREPARE final_stmt FROM @ddl; EXECUTE final_stmt; DEALLOCATE PREPARE final_stmt;

ALTER TABLE notificaciones MODIFY tipo ENUM(
 'POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE','CONADIS_ESTADO',
 'CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL','CLAVE_CAMBIADA','ACTIVIDAD_SOSPECHOSA','MENSAJE_SOPORTE'
) NOT NULL;

DROP TRIGGER IF EXISTS bi_conadis_obligatoria;
DROP TRIGGER IF EXISTS bu_conadis_obligatoria;
DROP TRIGGER IF EXISTS bd_conadis_auditada;
DELIMITER $$
CREATE TRIGGER bi_conadis_obligatoria BEFORE INSERT ON verificaciones_conadis FOR EACH ROW
BEGIN
    IF NEW.estado<>'PENDIENTE' OR NEW.id_revisor IS NOT NULL
       OR NEW.rui IS NULL OR TRIM(NEW.rui)=''
       OR NEW.carnet_archivo IS NULL OR TRIM(NEW.carnet_archivo)=''
       OR NEW.consentimiento_datos_at IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La solicitud inicial requiere consentimiento, RUI, fotografia y estado PENDIENTE.';
    END IF;
END$$
CREATE TRIGGER bu_conadis_obligatoria BEFORE UPDATE ON verificaciones_conadis FOR EACH ROW
BEGIN
    IF NEW.id_usuario<>OLD.id_usuario OR NEW.id_verificacion<>OLD.id_verificacion THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se puede cambiar el titular de la solicitud.';
    END IF;
    IF NEW.estado NOT IN ('PENDIENTE','APROBADA','RECHAZADA','VENCIDA')
       OR NEW.rui IS NULL OR TRIM(NEW.rui)=''
       OR NEW.carnet_archivo IS NULL OR TRIM(NEW.carnet_archivo)='' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La verificacion requiere estado, RUI y fotografia validos.';
    END IF;
    IF NEW.estado IN ('APROBADA','RECHAZADA','VENCIDA')
       AND (NEW.id_revisor IS NULL OR NOT EXISTS(
           SELECT 1 FROM usuarios u WHERE u.id_usuario=NEW.id_revisor
             AND u.rol='RECURSOS_HUMANOS' AND u.estado='activo')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La resolucion requiere un revisor de Recursos Humanos activo.';
    END IF;
    IF NEW.estado='APROBADA' AND (NEW.metodo IS NULL OR NEW.metodo<>'MANUAL'
       OR NEW.dni IS NULL OR NEW.nombres IS NULL OR NEW.apellidos IS NULL
       OR NEW.fecha_caducidad IS NULL OR NEW.fecha_caducidad<CURDATE()
       OR NEW.consentimiento_datos_at IS NULL OR NEW.fecha_revision IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La aprobacion manual requiere datos completos y vigentes.';
    END IF;
END$$
CREATE TRIGGER bd_conadis_auditada BEFORE DELETE ON verificaciones_conadis FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las solicitudes CONADIS auditadas no se eliminan.';
END$$
DELIMITER ;

CREATE TABLE IF NOT EXISTS esquema_version (
    version VARCHAR(20) PRIMARY KEY,
    fecha_aplicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO esquema_version(version) VALUES ('2026.10.31');

-- Perfiles demostrativos CONADIS y CV protegidos (2026-11-03).
SET @sofia=(SELECT id_usuario FROM usuarios WHERE correo='sofia@correo.com' AND rol='POSTULANTE' LIMIT 1);
SET @luis=(SELECT id_usuario FROM usuarios WHERE correo='luis@correo.com' AND rol='POSTULANTE' LIMIT 1);
SET @rrhh=(SELECT id_usuario FROM usuarios WHERE rol='RECURSOS_HUMANOS' AND estado='activo' ORDER BY id_usuario LIMIT 1);

INSERT INTO verificaciones_conadis(id_usuario,rui,carnet_archivo,estado,observacion_sistema,revision_rrhh,fecha_envio,consentimiento_datos_at)
SELECT @sofia,'406923','demo:conadis-sofia-ramirez.png','PENDIENTE','Solicitud demostrativa pendiente de revision manual.',1,NOW(),NOW()
WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM verificaciones_conadis WHERE id_usuario=@sofia);
INSERT INTO verificaciones_conadis(id_usuario,rui,carnet_archivo,estado,observacion_sistema,revision_rrhh,fecha_envio,consentimiento_datos_at)
SELECT @luis,'406924','demo:conadis-luis-torres.png','PENDIENTE','Solicitud demostrativa pendiente de revision manual.',1,NOW(),NOW()
WHERE @luis IS NOT NULL AND NOT EXISTS(SELECT 1 FROM verificaciones_conadis WHERE id_usuario=@luis);

UPDATE verificaciones_conadis SET rui='406923',dni='70568033',apellidos='RAMIREZ QUISPE',nombres='SOFIA VALERIA',
 carnet_archivo='demo:conadis-sofia-ramirez.png',fecha_caducidad='2030-12-31',estado='APROBADA',metodo='MANUAL',
 motivo='Registro demostrativo revisado por Recursos Humanos.',id_revisor=@rrhh,fecha_revision=NOW(),revision_rrhh=1,
 observacion_sistema='Revision manual de datos demostrativos; no equivale a una consulta oficial en linea.',consentimiento_datos_at=COALESCE(consentimiento_datos_at,NOW())
WHERE id_usuario=@sofia AND @rrhh IS NOT NULL;
UPDATE verificaciones_conadis SET rui='406924',dni='45687643',apellidos='TORRES MEDINA',nombres='LUIS ALBERTO',
 carnet_archivo='demo:conadis-luis-torres.png',fecha_caducidad='2030-12-31',estado='APROBADA',metodo='MANUAL',
 motivo='Registro demostrativo revisado por Recursos Humanos.',id_revisor=@rrhh,fecha_revision=NOW(),revision_rrhh=1,
 observacion_sistema='Revision manual de datos demostrativos; no equivale a una consulta oficial en linea.',consentimiento_datos_at=COALESCE(consentimiento_datos_at,NOW())
WHERE id_usuario=@luis AND @rrhh IS NOT NULL;

INSERT INTO historial_verificaciones_conadis(id_verificacion,id_usuario,rui,carnet_archivo,estado,motivo,id_revisor,accion,fecha_evento)
SELECT v.id_verificacion,v.id_usuario,v.rui,v.carnet_archivo,v.estado,v.motivo,v.id_revisor,'DATOS_DEMO_INTEGRADOS',NOW()
FROM verificaciones_conadis v WHERE v.id_usuario IN (@sofia,@luis)
AND NOT EXISTS(SELECT 1 FROM historial_verificaciones_conadis h WHERE h.id_verificacion=v.id_verificacion AND h.accion='DATOS_DEMO_INTEGRADOS');

INSERT INTO perfiles_postulantes(id_usuario,dni,telefono,habilidades,adaptacion_requerida,titular,ubicacion,acerca_de,cv_nombre,cv_archivo,cv_actualizado)
SELECT @sofia,'70568033','999111222','Java, MySQL, HTML, CSS, Bootstrap, soporte TI, trabajo en equipo','Indicaciones escritas, acceso fisico y modalidad hibrida','Estudiante de Ingenieria de Sistemas | Java, MySQL y soporte TI','San Juan de Lurigancho, Lima','Estudiante de Ingenieria de Sistemas interesada en desarrollo web, bases de datos y soporte tecnologico. Busca aportar en proyectos accesibles mediante documentacion clara, pruebas funcionales y trabajo colaborativo.','CV_Sofia_Ramirez.pdf','demo:cv-sofia-ramirez.pdf',NOW()
WHERE @sofia IS NOT NULL ON DUPLICATE KEY UPDATE dni=VALUES(dni),telefono=VALUES(telefono),habilidades=VALUES(habilidades),adaptacion_requerida=VALUES(adaptacion_requerida),titular=VALUES(titular),ubicacion=VALUES(ubicacion),acerca_de=VALUES(acerca_de),cv_nombre=VALUES(cv_nombre),cv_archivo=VALUES(cv_archivo),cv_actualizado=NOW();
INSERT INTO perfiles_postulantes(id_usuario,dni,telefono,habilidades,adaptacion_requerida,titular,ubicacion,acerca_de,cv_nombre,cv_archivo,cv_actualizado)
SELECT @luis,'45687643','988777666','Diseno grafico, redes sociales, redaccion y comunicacion digital','Compatibilidad con lector de pantalla, documentos accesibles y comunicacion escrita','Asistente de comunicacion digital | Diseno grafico y redes sociales','Lima, Peru','Postulante orientado a la comunicacion digital, el diseno de piezas visuales accesibles y la gestion de contenidos para redes sociales. Destaca por su redaccion clara, organizacion y disposicion para aprender.','CV_Luis_Torres.pdf','demo:cv-luis-torres.pdf',NOW()
WHERE @luis IS NOT NULL ON DUPLICATE KEY UPDATE dni=VALUES(dni),telefono=VALUES(telefono),habilidades=VALUES(habilidades),adaptacion_requerida=VALUES(adaptacion_requerida),titular=VALUES(titular),ubicacion=VALUES(ubicacion),acerca_de=VALUES(acerca_de),cv_nombre=VALUES(cv_nombre),cv_archivo=VALUES(cv_archivo),cv_actualizado=NOW();

INSERT INTO experiencias_postulante(id_usuario,cargo,organizacion,fecha_inicio,fecha_fin,descripcion)
SELECT @luis,'Practicante de comunicacion digital','Proyecto academico IncluyeLab','May. 2026','Oct. 2026','Experiencia demostrativa en redaccion de contenidos, preparacion de piezas graficas accesibles y apoyo en la organizacion de publicaciones para redes sociales.'
WHERE @luis IS NOT NULL AND NOT EXISTS(SELECT 1 FROM experiencias_postulante WHERE id_usuario=@luis AND organizacion='Proyecto academico IncluyeLab');
INSERT INTO educacion_postulante(id_usuario,institucion,carrera,fecha_inicio,fecha_fin,descripcion)
SELECT @luis,'Programa academico de demostracion IncluyeLab','Comunicacion digital y diseno grafico','Mar. 2025','Actualidad','Formacion demostrativa en redaccion digital, composicion visual, contenidos para redes sociales y accesibilidad de documentos.'
WHERE @luis IS NOT NULL AND NOT EXISTS(SELECT 1 FROM educacion_postulante WHERE id_usuario=@luis AND institucion='Programa academico de demostracion IncluyeLab');
INSERT INTO certificaciones_postulante(id_usuario,nombre,emisor,fecha_emision,credencial_url)
SELECT @luis,'Diseno de contenido digital accesible','IncluyeLab - contenido demostrativo','Sep. 2026',''
WHERE @luis IS NOT NULL AND NOT EXISTS(SELECT 1 FROM certificaciones_postulante WHERE id_usuario=@luis AND nombre='Diseno de contenido digital accesible');

INSERT IGNORE INTO esquema_version(version) VALUES ('2026.11.03');
