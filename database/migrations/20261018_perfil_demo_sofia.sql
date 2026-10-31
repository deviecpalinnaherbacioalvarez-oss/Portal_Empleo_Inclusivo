USE portal_empleo_inclusivo;
SET NAMES utf8mb4;

SET @sofia=(SELECT id_usuario FROM usuarios WHERE correo='sofia@correo.com' AND rol='POSTULANTE' LIMIT 1);

INSERT INTO perfiles_postulantes(id_usuario,telefono,habilidades,adaptacion_requerida,titular,ubicacion,acerca_de,foto_url)
SELECT @sofia,'999111222','Java, MySQL, HTML, CSS, Bootstrap, soporte TI, trabajo en equipo','Indicaciones escritas, herramientas compatibles con lector de pantalla y modalidad híbrida','Estudiante de Ingeniería de Sistemas | Java, MySQL y soporte TI','San Juan de Lurigancho, Lima','Perfil de demostración. Estudiante de Ingeniería de Sistemas interesada en desarrollo web, bases de datos y soporte tecnológico. Me motiva crear soluciones digitales accesibles, documentar procesos con claridad y colaborar en equipos diversos. Busco una oportunidad preprofesional para seguir aprendiendo y aportar con responsabilidad.', 'asset:perfil-sofia-demo.png'
WHERE @sofia IS NOT NULL
ON DUPLICATE KEY UPDATE telefono=VALUES(telefono),habilidades=VALUES(habilidades),adaptacion_requerida=VALUES(adaptacion_requerida),titular=VALUES(titular),ubicacion=VALUES(ubicacion),acerca_de=VALUES(acerca_de),foto_url=VALUES(foto_url);

INSERT INTO experiencias_postulante(id_usuario,cargo,organizacion,fecha_inicio,fecha_fin,descripcion)
SELECT @sofia,'Practicante de soporte y desarrollo web','Proyecto académico IncluyeLab','Abr. 2025','Dic. 2025','Experiencia ficticia de demostración: apoyo en pruebas funcionales, documentación de incidencias y construcción de interfaces accesibles con Java, JSP, Bootstrap y MySQL.'
WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM experiencias_postulante WHERE id_usuario=@sofia AND organizacion='Proyecto académico IncluyeLab');

INSERT INTO educacion_postulante(id_usuario,institucion,carrera,fecha_inicio,fecha_fin,descripcion)
SELECT @sofia,'Universidad Privada del Norte','Ingeniería de Sistemas Computacionales','Mar. 2023','Actualidad','Formación ficticia de demostración enfocada en programación, bases de datos, análisis de sistemas y desarrollo de aplicaciones web.'
WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM educacion_postulante WHERE id_usuario=@sofia AND institucion='Universidad Privada del Norte');

INSERT INTO certificaciones_postulante(id_usuario,nombre,emisor,fecha_emision,credencial_url)
SELECT @sofia,'Fundamentos de bases de datos','Programa académico de demostración','Ago. 2026',''
WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM certificaciones_postulante WHERE id_usuario=@sofia AND nombre='Fundamentos de bases de datos');

INSERT INTO certificaciones_postulante(id_usuario,nombre,emisor,fecha_emision,credencial_url)
SELECT @sofia,'Introducción a la accesibilidad web','IncluyeLab - contenido demostrativo','Sep. 2026',''
WHERE @sofia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM certificaciones_postulante WHERE id_usuario=@sofia AND nombre='Introducción a la accesibilidad web');

UPDATE experiencias_postulante SET cargo='Practicante de soporte y desarrollo web',organizacion='Proyecto académico IncluyeLab',fecha_inicio='Abr. 2025',fecha_fin='Dic. 2025',descripcion='Experiencia ficticia de demostración: apoyo en pruebas funcionales, documentación de incidencias y construcción de interfaces accesibles con Java, JSP, Bootstrap y MySQL.' WHERE id_usuario=@sofia AND cargo='Practicante de soporte y desarrollo web';
UPDATE educacion_postulante SET institucion='Universidad Privada del Norte',carrera='Ingeniería de Sistemas Computacionales',fecha_inicio='Mar. 2023',fecha_fin='Actualidad',descripcion='Formación ficticia de demostración enfocada en programación, bases de datos, análisis de sistemas y desarrollo de aplicaciones web.' WHERE id_usuario=@sofia AND institucion='Universidad Privada del Norte';
UPDATE certificaciones_postulante SET nombre='Fundamentos de bases de datos',emisor='Programa académico de demostración',fecha_emision='Ago. 2026' WHERE id_usuario=@sofia AND nombre='Fundamentos de bases de datos';
UPDATE certificaciones_postulante SET nombre='Introducción a la accesibilidad web',emisor='IncluyeLab - contenido demostrativo',fecha_emision='Sep. 2026' WHERE id_usuario=@sofia AND emisor='IncluyeLab - contenido demostrativo';
DELETE extra FROM experiencias_postulante extra JOIN experiencias_postulante conservar ON conservar.id_usuario=extra.id_usuario AND conservar.cargo=extra.cargo AND conservar.organizacion=extra.organizacion AND conservar.id_experiencia<extra.id_experiencia WHERE extra.id_usuario=@sofia AND extra.organizacion='Proyecto académico IncluyeLab';
DELETE extra FROM certificaciones_postulante extra JOIN certificaciones_postulante conservar ON conservar.id_usuario=extra.id_usuario AND conservar.nombre=extra.nombre AND conservar.emisor=extra.emisor AND conservar.id_certificacion<extra.id_certificacion WHERE extra.id_usuario=@sofia AND extra.emisor='IncluyeLab - contenido demostrativo';
