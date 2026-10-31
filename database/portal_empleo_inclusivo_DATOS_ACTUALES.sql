-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: portal_empleo_inclusivo
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `certificaciones_postulante`
--

DROP TABLE IF EXISTS `certificaciones_postulante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certificaciones_postulante` (
  `id_certificacion` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `nombre` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `emisor` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `credencial_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id_certificacion`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `certificaciones_postulante_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificaciones_postulante`
--

LOCK TABLES `certificaciones_postulante` WRITE;
/*!40000 ALTER TABLE `certificaciones_postulante` DISABLE KEYS */;
INSERT INTO `certificaciones_postulante` VALUES (1,3,'Fundamentos de bases de datos','Programa académico de demostración','Ago. 2026',''),(2,3,'Introducción a la accesibilidad web','IncluyeLab - contenido demostrativo','Sep. 2026','');
/*!40000 ALTER TABLE `certificaciones_postulante` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `educacion_postulante`
--

DROP TABLE IF EXISTS `educacion_postulante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `educacion_postulante` (
  `id_educacion` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `institucion` varchar(180) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `carrera` varchar(180) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_inicio` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_fin` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id_educacion`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `educacion_postulante_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `educacion_postulante`
--

LOCK TABLES `educacion_postulante` WRITE;
/*!40000 ALTER TABLE `educacion_postulante` DISABLE KEYS */;
INSERT INTO `educacion_postulante` VALUES (1,3,'Universidad Privada del Norte','Ingeniería de Sistemas Computacionales','Mar. 2023','Actualidad','Formación ficticia de demostración enfocada en programación, bases de datos, análisis de sistemas y desarrollo de aplicaciones web.');
/*!40000 ALTER TABLE `educacion_postulante` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empresas`
--

DROP TABLE IF EXISTS `empresas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empresas` (
  `id_empresa` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `razon_social` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruc` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sector` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sello_inclusivo` enum('Certificado','En revision','Pendiente') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pendiente',
  `logo_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitio_oficial` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pais` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Peru',
  `estado_revision` enum('pendiente','aprobada','rechazada') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `presentacion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `anio_inicio` int DEFAULT NULL,
  `logros` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `motivo_revision` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `version_revision` int NOT NULL DEFAULT '0',
  `fecha_revision` datetime DEFAULT NULL,
  `revisor_id` int DEFAULT NULL,
  PRIMARY KEY (`id_empresa`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `empresas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empresas`
--

LOCK TABLES `empresas` WRITE;
/*!40000 ALTER TABLE `empresas` DISABLE KEYS */;
INSERT INTO `empresas` (`id_empresa`,`id_usuario`,`razon_social`,`ruc`,`sector`,`sello_inclusivo`,`logo_url`,`estado_revision`,`presentacion`,`anio_inicio`,`logros`,`motivo_revision`,`version_revision`,`fecha_revision`,`revisor_id`) VALUES (1,2,'Microsoft','00000000000','Tecnologia','Pendiente','assets/logos/microsoft.png','aprobada',NULL,NULL,NULL,'',0,NULL,NULL),(2,5,'BCP','20100047218','Banca','Certificado','assets/logos/bcp.svg','aprobada',NULL,NULL,NULL,'',0,NULL,NULL),(3,6,'Interbank','20100053455','Banca','Certificado','assets/logos/interbank.svg','aprobada',NULL,NULL,NULL,'',0,NULL,NULL),(4,7,'Alicorp','20100055237','Consumo masivo','En revision','assets/logos/alicorp.png','aprobada',NULL,NULL,NULL,'',0,NULL,NULL),(5,8,'Rimac Seguros','20100041953','Seguros','Certificado','assets/logos/rimac.png','aprobada',NULL,NULL,NULL,'',0,NULL,NULL),(6,9,'Entel Peru','20543254798','Telecomunicaciones','En revision','assets/logos/entel.webp','aprobada',NULL,NULL,NULL,'',0,NULL,NULL),(7,10,'Sodimac Peru','20389230724','Retail','Certificado','assets/logos/sodimac.png','aprobada',NULL,NULL,NULL,'',0,NULL,NULL),(8,11,'Inkafarma','20100028698','Salud y retail','Certificado','assets/logos/inkafarma.png','aprobada',NULL,NULL,NULL,'',0,NULL,NULL),(9,12,'Yape','20538888029','Fintech','Certificado','assets/logos/yape.png','aprobada',NULL,NULL,NULL,'',0,NULL,NULL);
UPDATE empresas SET sitio_oficial=CASE razon_social WHEN 'Microsoft' THEN 'https://www.microsoft.com/' WHEN 'BCP' THEN 'https://www.viabcp.com/' WHEN 'Interbank' THEN 'https://interbank.pe/' WHEN 'Alicorp' THEN 'https://www.alicorp.com.pe/' WHEN 'Rimac Seguros' THEN 'https://www.rimac.com/' WHEN 'Entel Peru' THEN 'https://www.entel.pe/' WHEN 'Sodimac Peru' THEN 'https://www.sodimac.com.pe/' WHEN 'Inkafarma' THEN 'https://inkafarma.pe/' WHEN 'Yape' THEN 'https://www.yape.com.pe/' ELSE sitio_oficial END, pais=CASE WHEN razon_social='Microsoft' THEN 'Internacional' ELSE 'Peru' END;
/*!40000 ALTER TABLE `empresas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evaluaciones_rrhh`
--

DROP TABLE IF EXISTS `evaluaciones_rrhh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evaluaciones_rrhh` (
  `id_evaluacion` int NOT NULL AUTO_INCREMENT,
  `id_postulacion` int NOT NULL,
  `id_evaluador` int NOT NULL,
  `observaciones` varchar(4000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resultado` enum('PENDIENTE','APROBADO','NO_APROBADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `estado` enum('BORRADOR','PUBLICADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'BORRADOR',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `puntaje_cv` tinyint unsigned NOT NULL DEFAULT '0',
  `puntaje_entrevista` tinyint unsigned NOT NULL DEFAULT '0',
  `puntaje_desempeno` tinyint unsigned NOT NULL DEFAULT '0',
  `porcentaje_compatibilidad` tinyint unsigned NOT NULL DEFAULT '0',
  `etapa` enum('REVISION_CV','ENTREVISTA','DESEMPENO','FINAL') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'REVISION_CV',
  `retroalimentacion` varchar(4000) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id_evaluacion`),
  UNIQUE KEY `uq_evaluacion_rrhh` (`id_postulacion`,`id_evaluador`),
  KEY `fk_evaluacion_evaluador` (`id_evaluador`),
  CONSTRAINT `fk_evaluacion_evaluador` FOREIGN KEY (`id_evaluador`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `fk_evaluacion_postulacion` FOREIGN KEY (`id_postulacion`) REFERENCES `postulaciones` (`id_postulacion`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evaluaciones_rrhh`
--

LOCK TABLES `evaluaciones_rrhh` WRITE;
/*!40000 ALTER TABLE `evaluaciones_rrhh` DISABLE KEYS */;
/*!40000 ALTER TABLE `evaluaciones_rrhh` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiencias_postulante`
--

DROP TABLE IF EXISTS `experiencias_postulante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiencias_postulante` (
  `id_experiencia` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `cargo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `organizacion` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_inicio` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_fin` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id_experiencia`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `experiencias_postulante_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiencias_postulante`
--

LOCK TABLES `experiencias_postulante` WRITE;
/*!40000 ALTER TABLE `experiencias_postulante` DISABLE KEYS */;
INSERT INTO `experiencias_postulante` VALUES (1,3,'Practicante de soporte y desarrollo web','Proyecto académico IncluyeLab','Abr. 2025','Dic. 2025','Experiencia ficticia de demostración: apoyo en pruebas funcionales, documentación de incidencias y construcción de interfaces accesibles con Java, JSP, Bootstrap y MySQL.');
/*!40000 ALTER TABLE `experiencias_postulante` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `incidencias_soporte`
--

DROP TABLE IF EXISTS `incidencias_soporte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `incidencias_soporte` (
  `id_incidencia` int NOT NULL AUTO_INCREMENT,
  `id_creador` int DEFAULT NULL,
  `id_responsable` int NOT NULL,
  `id_usuario_afectado` int DEFAULT NULL,
  `correo` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `titulo` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(4000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `origen` enum('EXTERNA','INTERNA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'EXTERNA',
  `categoria` enum('SEGURIDAD','ACCESO','INFRACCION','TECNICO','OTRO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'TECNICO',
  `prioridad` enum('BAJA','MEDIA','ALTA','URGENTE') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'MEDIA',
  `decision` enum('PENDIENTE','ACEPTADA','RECHAZADA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `estado` enum('PENDIENTE','EN_PROCESO','RESUELTA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `solucion` varchar(4000) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_incidencia`),
  KEY `fk_incidencia_creador` (`id_creador`),
  KEY `fk_incidencia_responsable` (`id_responsable`),
  KEY `fk_incidencia_usuario_afectado` (`id_usuario_afectado`),
  CONSTRAINT `fk_incidencia_creador` FOREIGN KEY (`id_creador`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_incidencia_responsable` FOREIGN KEY (`id_responsable`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `fk_incidencia_usuario_afectado` FOREIGN KEY (`id_usuario_afectado`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `incidencias_soporte`
--

LOCK TABLES `incidencias_soporte` WRITE;
/*!40000 ALTER TABLE `incidencias_soporte` DISABLE KEYS */;
/*!40000 ALTER TABLE `incidencias_soporte` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificaciones`
--

DROP TABLE IF EXISTS `notificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notificaciones` (
  `id_notificacion` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `tipo` enum('POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `titulo` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mensaje` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `leida` tinyint(1) NOT NULL DEFAULT '0',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_notificacion`),
  KEY `idx_notificacion_usuario_fecha` (`id_usuario`,`fecha_creacion`),
  CONSTRAINT `fk_notificacion_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificaciones`
--

LOCK TABLES `notificaciones` WRITE;
/*!40000 ALTER TABLE `notificaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `notificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ofertas`
--

DROP TABLE IF EXISTS `ofertas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ofertas` (
  `id_oferta` int NOT NULL AUTO_INCREMENT,
  `id_empresa` int NOT NULL,
  `titulo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `modalidad` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ubicacion` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `adaptaciones` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `salario` decimal(10,2) NOT NULL DEFAULT '0.00',
  `estado` enum('activa','cerrada') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activa',
  `fecha_publicacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `apoyos` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id_oferta`),
  KEY `id_empresa` (`id_empresa`),
  CONSTRAINT `ofertas_ibfk_1` FOREIGN KEY (`id_empresa`) REFERENCES `empresas` (`id_empresa`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ofertas`
--

LOCK TABLES `ofertas` WRITE;
/*!40000 ALTER TABLE `ofertas` DISABLE KEYS */;
INSERT INTO `ofertas` VALUES (1,1,'Asistente de soporte remoto','Remoto','Lima','Horario flexible, lector de pantalla, reuniones grabadas','## Acerca del empleo\nMicrosoft busca una persona orientada al servicio para brindar soporte remoto accesible a usuarios internos.\n## Funciones principales\n- Atender y clasificar solicitudes mediante la mesa de ayuda.\n- Diagnosticar problemas de Windows, Microsoft 365 y conectividad.\n- Guiar al usuario por llamada, chat o herramienta de asistencia remota.\n- Documentar la solución aplicada y escalar incidentes complejos.\n## Formación\nEstudios técnicos o universitarios en Sistemas, Informática, Redes o carreras afines.\n## Experiencia\nSeis meses de experiencia en soporte técnico o atención de incidencias. Se consideran prácticas preprofesionales.\n## Conocimientos técnicos\n- Windows 10 y 11, Microsoft 365 y configuración de periféricos.\n- Conceptos básicos de redes, acceso remoto y seguridad digital.\n- Registro de tickets y elaboración de documentación técnica.\n## Condiciones laborales\n- Modalidad remota desde Lima.\n- Jornada de lunes a viernes con horario flexible.\n- Equipo de trabajo y capacitación inicial proporcionados por la empresa.',1800.00,'activa','2026-10-02 17:31:36','lector,flexible'),(2,1,'Auxiliar administrativo inclusivo','Presencial accesible','San Juan de Lurigancho','Rampa, ascensor, escritorio ergonomico','## Acerca del empleo\nMicrosoft requiere apoyo administrativo para organizar documentación y atender solicitudes internas en una oficina accesible.\n## Funciones principales\n- Registrar, digitalizar y archivar documentos administrativos.\n- Actualizar bases de datos y cuadros de seguimiento.\n- Coordinar reuniones y atender consultas de colaboradores.\n- Preparar reportes sencillos y controlar la recepción de documentos.\n## Formación\nEstudios técnicos o universitarios en Administración, Contabilidad, Gestión Documental o carreras afines.\n## Experiencia\nSeis meses en labores administrativas, archivo o atención interna. Se aceptan prácticas.\n## Conocimientos técnicos\n- Microsoft Word, Excel y correo electrónico.\n- Organización de archivos físicos y digitales.\n- Redacción y comunicación profesional.\n## Condiciones laborales\n- Trabajo presencial accesible en San Juan de Lurigancho.\n- Horario de lunes a viernes de 8:30 a. m. a 5:30 p. m.\n- Rampa, ascensor y escritorio ergonómico disponibles.',1500.00,'activa','2026-10-02 17:31:36','rampas,ascensores'),(3,1,'Analista junior de datos','Hibrido','Lima Centro','Capacitacion inicial, mentor asignado, herramientas accesibles','## Acerca del empleo\nMicrosoft incorpora talento junior para transformar información operativa en reportes útiles para la toma de decisiones.\n## Funciones principales\n- Limpiar, ordenar y validar bases de datos.\n- Elaborar reportes e indicadores periódicos.\n- Apoyar en la construcción de tableros y controles de calidad.\n- Documentar fuentes, reglas y resultados del análisis.\n## Formación\nEgresado o estudiante de últimos ciclos de Sistemas, Estadística, Ingeniería Industrial, Economía o carreras afines.\n## Experiencia\nUn año en análisis de datos, reportes o prácticas relacionadas.\n## Conocimientos técnicos\n- Excel intermedio o avanzado y consultas SQL.\n- Power BI o herramienta equivalente de visualización.\n- Fundamentos de calidad y protección de datos.\n## Condiciones laborales\n- Modalidad híbrida en Lima Centro.\n- Jornada de lunes a viernes.\n- Mentor asignado, capacitación inicial y herramientas accesibles.',2200.00,'activa','2026-10-02 17:31:36',''),(4,2,'Asistente de experiencia al cliente inclusivo','Hibrido','Lima, Peru','Lector de pantalla, horario flexible, reuniones con subtitulos','## Acerca del empleo\nBCP busca una persona que acompañe a clientes por canales digitales y contribuya a una experiencia bancaria clara e inclusiva.\n## Funciones principales\n- Atender consultas por chat, correo y canales telefónicos accesibles.\n- Orientar sobre productos, operaciones y medidas de seguridad.\n- Registrar solicitudes y realizar seguimiento hasta su solución.\n- Identificar oportunidades de mejora en la experiencia del cliente.\n## Formación\nEstudios técnicos o universitarios en Administración, Comunicaciones, Marketing, Banca o carreras afines.\n## Experiencia\nUn año en atención al cliente, soporte o canales digitales.\n## Conocimientos técnicos\n- Manejo de CRM, Microsoft Office y canales de atención.\n- Comunicación escrita, protección de datos y prevención de fraude.\n## Condiciones laborales\n- Modalidad híbrida en Lima.\n- Horario rotativo dentro de la jornada establecida.\n- Lector de pantalla, subtítulos y flexibilidad coordinada.',2400.00,'activa','2026-10-02 18:14:39','lector,subtitulos,flexible'),(5,3,'Practicante de tecnologia accesible','Hibrido','San Isidro, Lima','Mentor asignado, laptop adaptada, espacios sin barreras','## Acerca del empleo\nInterbank ofrece una práctica para participar en iniciativas de tecnología y accesibilidad digital con acompañamiento de un mentor.\n## Funciones principales\n- Ejecutar pruebas funcionales y de accesibilidad en aplicaciones web.\n- Registrar incidencias con pasos claros y evidencias.\n- Apoyar en documentación técnica y seguimiento de mejoras.\n- Participar en reuniones de planificación y revisión del equipo.\n## Formación\nEstudiante desde sexto ciclo de Ingeniería de Sistemas, Software, Informática o carreras afines.\n## Experiencia\nNo se requiere experiencia laboral. Se valoran proyectos académicos o personales.\n## Conocimientos técnicos\n- Fundamentos de HTML, CSS, JavaScript y bases de datos.\n- Conceptos de pruebas de software y accesibilidad WCAG.\n- Manejo básico de Git y herramientas colaborativas.\n## Condiciones laborales\n- Práctica híbrida en San Isidro.\n- Jornada compatible con estudios.\n- Laptop adaptada, mentor y espacios sin barreras.',1800.00,'activa','2026-10-02 18:14:39',''),(6,4,'Analista de datos junior','Remoto','Peru','Trabajo remoto, comunicacion escrita, pausas sensoriales','## Acerca del empleo\nAlicorp busca talento junior para analizar información comercial y mejorar el seguimiento de indicadores del negocio.\n## Funciones principales\n- Consolidar información de ventas y operaciones.\n- Elaborar tableros y reportes automáticos.\n- Verificar consistencia de datos y comunicar hallazgos.\n- Apoyar en proyecciones y análisis de tendencias.\n## Formación\nEgresado de Estadística, Sistemas, Ingeniería Industrial, Economía o carreras afines.\n## Experiencia\nUn año en análisis, reportería o inteligencia de negocios.\n## Conocimientos técnicos\n- SQL, Excel avanzado y Power BI.\n- Modelado básico de datos y presentación de indicadores.\n- Deseable conocimiento de Python.\n## Condiciones laborales\n- Trabajo remoto desde Perú.\n- Jornada de lunes a viernes con pausas coordinadas.\n- Comunicación escrita y reuniones virtuales estructuradas.',2600.00,'activa','2026-10-02 18:14:39','escrita'),(7,5,'Ejecutivo de soporte administrativo','Presencial accesible','Miraflores, Lima','Ascensor, rutas accesibles, interprete LS previa coordinacion','## Acerca del empleo\nRímac Seguros requiere soporte administrativo para mantener expedientes y solicitudes internas correctamente organizados.\n## Funciones principales\n- Revisar, registrar y archivar documentación.\n- Actualizar estados de solicitudes en los sistemas internos.\n- Coordinar atenciones con diferentes áreas.\n- Elaborar reportes de seguimiento y alertar casos pendientes.\n## Formación\nTécnico o universitario en Administración, Seguros, Contabilidad o carreras afines.\n## Experiencia\nUn año en gestión documental, operaciones o soporte administrativo.\n## Conocimientos técnicos\n- Excel intermedio, Microsoft 365 y sistemas de gestión.\n- Redacción de correos y manejo confidencial de información.\n## Condiciones laborales\n- Trabajo presencial accesible en Miraflores.\n- Horario de lunes a viernes de 9:00 a. m. a 6:00 p. m.\n- Ascensor, rutas accesibles e intérprete de LSP previa coordinación.',2300.00,'activa','2026-10-02 18:14:39','ascensores'),(8,6,'Asesor de atencion digital','Remoto','Lima y provincias','Software lector, capacitacion inclusiva, horario flexible','## Acerca del empleo\nEntel Perú busca una persona para resolver consultas y requerimientos mediante canales digitales accesibles.\n## Funciones principales\n- Atender clientes por chat, correo y redes sociales.\n- Resolver consultas sobre servicios, facturación y configuración básica.\n- Registrar cada atención y escalar incidencias técnicas.\n- Cumplir indicadores de calidad y satisfacción.\n## Formación\nEstudios técnicos o universitarios en Comunicaciones, Administración, Sistemas o carreras afines.\n## Experiencia\nSeis meses en atención al cliente, soporte o contact center.\n## Conocimientos técnicos\n- Manejo de CRM, herramientas ofimáticas y comunicación digital.\n- Conceptos básicos de telefonía móvil e internet.\n## Condiciones laborales\n- Modalidad remota para Lima y provincias.\n- Horarios rotativos y pausas activas.\n- Software lector y capacitación inclusiva.',1900.00,'activa','2026-10-02 18:14:39','lector,flexible'),(9,7,'Auxiliar de tienda con accesibilidad','Presencial accesible','Ate, Lima','Rampas, senalizacion clara, acompanamiento inicial','## Acerca del empleo\nSodimac Perú incorpora una persona para apoyar en la operación de tienda y brindar orientación accesible a clientes.\n## Funciones principales\n- Reponer y ordenar mercadería liviana.\n- Verificar precios, etiquetas y disponibilidad de productos.\n- Orientar a clientes y derivar consultas especializadas.\n- Mantener despejadas y seguras las rutas de circulación.\n## Formación\nSecundaria completa. Se valoran estudios técnicos en curso.\n## Experiencia\nNo indispensable. Se valora experiencia en tienda, almacén o atención al cliente.\n## Conocimientos técnicos\n- Atención al cliente y organización de productos.\n- Manejo básico de equipos móviles o sistema de inventario.\n## Condiciones laborales\n- Trabajo presencial accesible en Ate.\n- Turnos rotativos de ocho horas.\n- Rampas, señalización clara y acompañamiento inicial.',1600.00,'activa','2026-10-02 18:14:39','rampas'),(10,8,'Asistente de operaciones farmaceuticas','Hibrido','Lima Norte','Entorno guiado, capacitacion por pasos, comunicacion visual','## Acerca del empleo\nInkafarma busca apoyo para registrar información operativa y coordinar requerimientos de sus establecimientos.\n## Funciones principales\n- Actualizar controles de inventario y operación.\n- Registrar incidencias y realizar seguimiento con las áreas responsables.\n- Preparar reportes y validar documentación de farmacia.\n- Apoyar en coordinaciones con establecimientos y proveedores.\n## Formación\nTécnico o universitario en Administración, Farmacia, Ingeniería Industrial o carreras afines.\n## Experiencia\nSeis meses en operaciones, inventarios o soporte administrativo.\n## Conocimientos técnicos\n- Excel intermedio y manejo de sistemas de registro.\n- Conceptos básicos de inventario y trazabilidad.\n- Comunicación escrita y organización documental.\n## Condiciones laborales\n- Modalidad híbrida en Lima Norte.\n- Horario de lunes a viernes y sábado medio día según programación.\n- Entorno guiado, comunicación visual y capacitación paso a paso.',1700.00,'activa','2026-10-02 18:14:39',''),(11,9,'Analista junior de producto digital','Hibrido','La Molina, Lima','Subtitulos, lector de pantalla, reuniones grabadas','## Acerca del empleo\nYape busca talento junior para apoyar en la evolución de funcionalidades digitales y analizar la experiencia de sus usuarios.\n## Funciones principales\n- Dar seguimiento al backlog y a los entregables del producto.\n- Analizar indicadores de uso y preparar reportes.\n- Participar en pruebas funcionales y documentar resultados.\n- Recoger necesidades de usuarios y coordinar con diseño y tecnología.\n## Formación\nEgresado de Ingeniería de Sistemas, Industrial, Administración, Diseño de Producto o carreras afines.\n## Experiencia\nUn año en producto digital, análisis de negocio, proyectos o experiencia de usuario.\n## Conocimientos técnicos\n- Metodologías ágiles, Jira o herramienta equivalente.\n- Excel o Google Sheets, SQL básico y analítica digital.\n- Pruebas funcionales y documentación de historias de usuario.\n## Condiciones laborales\n- Modalidad híbrida en La Molina.\n- Jornada de lunes a viernes.\n- Reuniones con subtítulos, grabaciones y compatibilidad con lector de pantalla.',2800.00,'activa','2026-10-02 18:14:39','lector,subtitulos');
/*!40000 ALTER TABLE `ofertas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perfiles_postulantes`
--

DROP TABLE IF EXISTS `perfiles_postulantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perfiles_postulantes` (
  `id_perfil` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `dni` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `habilidades` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo_discapacidad` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `adaptacion_requerida` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `experiencia` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `titular` varchar(160) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `ubicacion` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `acerca_de` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `foto_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `cv_nombre` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `cv_archivo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `cv_actualizado` datetime DEFAULT NULL,
  PRIMARY KEY (`id_perfil`),
  UNIQUE KEY `uq_perfil_usuario` (`id_usuario`),
  CONSTRAINT `perfiles_postulantes_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfiles_postulantes`
--

LOCK TABLES `perfiles_postulantes` WRITE;
/*!40000 ALTER TABLE `perfiles_postulantes` DISABLE KEYS */;
INSERT INTO `perfiles_postulantes` VALUES (1,3,'70112233','999111222','Java, MySQL, HTML, CSS, Bootstrap, soporte TI, trabajo en equipo','Movilidad reducida','Indicaciones escritas, herramientas compatibles con lector de pantalla y modalidad híbrida','Experiencia en soporte administrativo.','Estudiante de Ingeniería de Sistemas | Java, MySQL y soporte TI','San Juan de Lurigancho, Lima','Perfil de demostración. Estudiante de Ingeniería de Sistemas interesada en desarrollo web, bases de datos y soporte tecnológico. Me motiva crear soluciones digitales accesibles, documentar procesos con claridad y colaborar en equipos diversos. Busco una oportunidad preprofesional para seguir aprendiendo y aportar con responsabilidad.','asset:perfil-sofia-demo.png','','',NULL),(2,4,'71223344','988777666','Diseno grafico, redes sociales, redaccion','Visual leve','Compatibilidad con lector de pantalla','Practicas en comunicacion digital.','','',NULL,'','','',NULL);
/*!40000 ALTER TABLE `perfiles_postulantes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `postulaciones`
--

DROP TABLE IF EXISTS `postulaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `postulaciones` (
  `id_postulacion` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `id_oferta` int NOT NULL,
  `estado` enum('pendiente','en revision','aceptado','rechazado') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `fecha_postulacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_postulacion`),
  KEY `id_usuario` (`id_usuario`),
  KEY `id_oferta` (`id_oferta`),
  CONSTRAINT `postulaciones_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `postulaciones_ibfk_2` FOREIGN KEY (`id_oferta`) REFERENCES `ofertas` (`id_oferta`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `postulaciones`
--

LOCK TABLES `postulaciones` WRITE;
/*!40000 ALTER TABLE `postulaciones` DISABLE KEYS */;
INSERT INTO `postulaciones` VALUES (1,3,1,'pendiente','2026-10-02 17:31:36'),(9,3,9,'pendiente','2026-10-18 21:12:52'),(10,32,10,'pendiente','2026-10-20 12:32:39');
/*!40000 ALTER TABLE `postulaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contrasena` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` enum('ADMIN','POSTULANTE','EMPRESA','RECURSOS_HUMANOS','SOPORTE_TECNICO') COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado` enum('activo','inactivo') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activo',
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `intentos_fallidos` tinyint unsigned NOT NULL DEFAULT '0',
  `bloqueado_hasta` datetime DEFAULT NULL,
  `requiere_cambio_clave` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Administrador Principal','admin@incluyelab.pe','123456','ADMIN','activo','2026-10-02 17:31:36',0,NULL,0),(2,'Microsoft (cuenta demo)','empresa@incluyelab.pe','pbkdf2$600000$qrtkZkdmeXoyvfsp0/hG7A==$7Lef4LXBWSF8i9pk3Q9O19cfhbnOw5u8g8M62+bJDBA=','EMPRESA','activo','2026-10-02 17:31:36',0,NULL,0),(3,'Sofia Ramirez','sofia@correo.com','123456','POSTULANTE','activo','2026-10-02 17:31:36',0,NULL,0),(4,'Luis Torres','luis@correo.com','123456','POSTULANTE','activo','2026-10-02 17:31:36',0,NULL,0),(5,'Banco de Credito del Peru','talento@bcp.com.pe','pbkdf2$600000$r11xuXBz+nprNhnSlE3slg==$xDjqHQ2B7nZUeRgwMvFAc0XPFg7XCjgMC57f+z8sPPo=','EMPRESA','activo','2026-10-02 18:14:39',0,NULL,0),(6,'Interbank','empleos@interbank.pe','pbkdf2$600000$ZBNa8p+2Z5/ZApyx5y0KHw==$7sBamU60mP5Vty/mzHCucmCjt/75stNPaDEJ+io25rU=','EMPRESA','activo','2026-10-02 18:14:39',0,NULL,0),(7,'Alicorp','personas@alicorp.com.pe','pbkdf2$600000$LDiQTNMG7YrYbUscB8d+ZQ==$8qKrxCRztQS/VDpP6sLOISgSz/u4fFv5FqrWo63Ucr0=','EMPRESA','activo','2026-10-02 18:14:39',0,NULL,0),(8,'Rimac Seguros','inclusion@rimac.com','pbkdf2$600000$iY/9qfKS6jgFpVX9jQuCrQ==$0YD6ToFxdSUFzlsxHFeZP1AIHHFdHJdr9n8Xm2EXzCA=','EMPRESA','activo','2026-10-02 18:14:39',0,NULL,0),(9,'Entel Peru','talento@entel.pe','pbkdf2$600000$MXQp3N5+HTHRxAYXyZ/79w==$bZB+QSoqXy2D2ZAbD0Nb2ho5OEXfvkcUPZY/Eo0/AbQ=','EMPRESA','activo','2026-10-02 18:14:39',0,NULL,0),(10,'Sodimac Peru','empleos@sodimac.com.pe','pbkdf2$600000$DvhUHGAVyJXv7G3lJZLWBQ==$3HljT9FiyPetaFp6FYvMiLxoB+LLSS4vgat+bR6NYzQ=','EMPRESA','activo','2026-10-02 18:14:39',0,NULL,0),(11,'Inkafarma','trabaja@inkafarma.pe','pbkdf2$600000$XYsX8xqH4zJ1K/hTOxBchg==$eHPJVJOsmJGvoJIJTLXgHYN+EoC9pGRUKHIHo4RJcHI=','EMPRESA','activo','2026-10-02 18:14:39',0,NULL,0),(12,'Yape','talento@yape.com.pe','pbkdf2$600000$DCa7bH93rSbpoS/cwhzqGg==$mrCuLmiPaOBIM19bDMd0sP1kGOMdSl+uPdxOgvLRZXI=','EMPRESA','activo','2026-10-02 18:14:39',0,NULL,0),(32,'Marco Salcedo ','marcosalcedo@gmail.com','pbkdf2$600000$SC2nJ+C3Wumk5+BcvRgYbw==$gTz4GCTjDNUjwTz+jwEQwuiQaNvCk9yoLhu32JVFcV8=','POSTULANTE','activo','2026-10-20 12:31:58',0,NULL,0),(33,'Daniel Angel Advincula Miraval','daniel.advincula@incluyelab.com','pbkdf2$600000$M27ETomKEgpzEHzCwgWBIA==$6cu5f2NyPXGXO8dNvglqONdEEhgjzjPpobS3y8if0f4=','SOPORTE_TECNICO','activo','2026-10-21 05:02:55',0,NULL,0),(34,'Marco Polo Salcedo Castillo','marco.salcedo@incluyelab.com','pbkdf2$600000$YEughiPdU0O7j8BhfRexiA==$dFI0SjRyPsRtdHoHhA9cphzKqM9GJGySANkRaFYcI7U=','RECURSOS_HUMANOS','activo','2026-10-21 05:02:55',0,NULL,0);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'portal_empleo_inclusivo'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-21 11:55:04


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
ALTER TABLE usuarios ADD COLUMN clave_temporal_expira DATETIME NULL, ADD COLUMN motivo_bloqueo VARCHAR(500) NOT NULL DEFAULT '';
ALTER TABLE incidencias_soporte ADD COLUMN numero_ticket VARCHAR(30) NULL, ADD COLUMN identidad_verificada TINYINT(1) NOT NULL DEFAULT 0, ADD COLUMN metodo_verificacion VARCHAR(80) NOT NULL DEFAULT '', ADD COLUMN motivo_accion VARCHAR(1000) NOT NULL DEFAULT '', ADD COLUMN fecha_verificacion DATETIME NULL;
UPDATE incidencias_soporte SET numero_ticket=CONCAT('INC-',LPAD(id_incidencia,8,'0')) WHERE numero_ticket IS NULL OR numero_ticket='';
ALTER TABLE incidencias_soporte MODIFY numero_ticket VARCHAR(30) NOT NULL, ADD UNIQUE KEY uq_incidencia_ticket(numero_ticket);
ALTER TABLE notificaciones MODIFY tipo ENUM('POSTULACION_ELIMINADA','OFERTA_ELIMINADA','REPORTE_SOPORTE','CONADIS_ESTADO','CUENTA_DESBLOQUEADA','CLAVE_TEMPORAL','CLAVE_CAMBIADA','ACTIVIDAD_SOSPECHOSA','MENSAJE_SOPORTE') NOT NULL;
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
