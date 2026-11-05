# IncluyeLab: evidencia tecnica para la rubrica

## T2: cinco CRUD con Stored Procedures

La migracion `database/migrations/20261104_crud_stored_procedures.sql` instala
25 procedimientos para cinco CRUD reales: cuentas internas, ofertas,
postulaciones, evaluaciones de Recursos Humanos e incidencias de Soporte.
Los DAO los invocan mediante `CallableStatement`; no son procedimientos de
demostracion desconectados de la web. `database/verificar_instalacion.sql`
comprueba cada nombre esperado. La prueba reproducible
`database/tests/probar_crud_procedimientos.sql` ejecuta C/R/U/D y finaliza con
`CRUD_5_OK_ROLLBACK_LIMPIO`, sin conservar registros temporales.

Actualizacion: 4 de noviembre de 2026 (Peru).
La presentacion en clase la prepara el estudiante. Este documento ubica el
codigo y las funciones para demostrar la parte tecnica; no garantiza una nota.

## 1. Control de sesiones de login y redireccionamiento (3 puntos)

- Login consulta MySQL y acepta solamente cuentas activas.
- Una autenticacion correcta crea una sesion nueva (evita reutilizar el ID anterior).
- Redireccion por rol: ADMIN -> /admin, EMPRESA -> /empresa, POSTULANTE -> /postulante,
  RECURSOS_HUMANOS -> /recursos-humanos y SOPORTE_TECNICO -> /soporte-tecnico.
- Si el postulante venia del detalle de una oferta, vuelve a esa oferta para postular.
- Un usuario ya autenticado que abre login o registro vuelve a su panel.
- Las rutas y JSP privados requieren sesion. Un visitante recibe redireccion a login.
- Un usuario de otro rol no puede abrir el panel ajeno: vuelve al suyo.
- Las escrituras sin autorizacion devuelven HTTP 403 y no se ejecutan.
- Cada solicitud dinamica revalida el estado y rol del usuario en MySQL.
  Desactivar la cuenta o cambiar su rol invalida la sesion anterior.
- Cerrar sesion la invalida. Las pantallas dinamicas llevan Cache-Control: no-store.
- Inactividad: 30 minutos, configurados en web.xml y al iniciar sesion.
- Cookie de sesion HttpOnly; identificacion por cookie, no por URL.

Archivos:
- src/main/java/com/incluyelab/filter/SesionFilter.java
- src/main/java/com/incluyelab/servlet/LoginServlet.java
- src/main/java/com/incluyelab/servlet/LogoutServlet.java
- src/main/java/com/incluyelab/dao/UsuarioDAO.java
- src/main/webapp/WEB-INF/web.xml

La prueba automatizada comprueba rechazo de cookies de sesiones invalidadas.
El plazo de 30 minutos esta configurado; no se espera media hora en cada prueba.

## 2. Website completo con Bootstrap y JSP (5 puntos)

Pantallas JSP: index, login, registro, postulante, empresa y admin.
Bootstrap 5.3.8 local: formularios, grilla responsive, tablas y avisos interactivos.
JavaScript conserva filtros, detalle, favoritos y preferencias de accesibilidad.
Las vistas se comprobaron a 390, 768 y 1440 px, con alto contraste y texto ampliado.
Las ofertas provienen de MySQL; no son solamente tarjetas estaticas.

Archivos:
- src/main/webapp/*.jsp
- src/main/webapp/WEB-INF/jspf/head.jspf
- src/main/webapp/assets/vendor/bootstrap.min.css
- src/main/webapp/assets/vendor/bootstrap.bundle.min.js
- src/main/webapp/assets/css/styles.css
- src/main/webapp/assets/js/app.js

## 3. Administracion y CRUD por propietario

El Administrador Central gestiona cuentas internas y consulta empresas, ofertas,
postulaciones, evaluaciones e incidencias. No modifica operaciones que pertenecen
a Empresa, Postulante, Recursos Humanos o Soporte Tecnico.
Los CRUD funcionales se distribuyen por propietario: cuentas internas en
Administracion, ofertas en Empresa, postulaciones en Postulante/Empresa,
evaluaciones en Recursos Humanos e incidencias en Soporte Tecnico.

Archivos:
- src/main/webapp/admin.jsp
- src/main/webapp/WEB-INF/admin-form.jsp
- src/main/webapp/WEB-INF/admin-delete.jsp
- src/main/java/com/incluyelab/servlet/AdminServlet.java
- src/main/java/com/incluyelab/dao/AdminDAO.java
- src/main/java/com/incluyelab/model/ (JavaBeans)

Eliminar exige confirmacion y POST. Las claves foraneas bloquean eliminaciones
con dependencias. El administrador no puede eliminar/desactivar su propia cuenta.
Las escrituras administrativas validan un token CSRF.
Al editar una postulacion solo cambia su estado; conserva oferta y postulante.

### CRUD adicionales por rol

- Recursos Humanos: CRUD de evaluaciones vinculadas a postulaciones reales.
  Puede consultar candidatos y CV, crear evaluaciones, actualizarlas y eliminar
  solamente borradores propios.
- Soporte Tecnico: CRUD de incidencias. Recibe reportes publicos, crea incidencias
  internas, actualiza prioridad/decision/estado/solucion y elimina solamente las
  incidencias internas propias que aun estan pendientes.
- Los roles no se mezclan: el filtro de sesion impide abrir el panel ajeno.
- Tablas: `evaluaciones_rrhh` e `incidencias_soporte`.
- Migracion: `database/migrations/20261021_crud_rrhh_soporte.sql`.
- Archivos principales: `RecursosHumanosServlet`, `SoporteTecnicoServlet`,
  `RecursosHumanosDAO`, `IncidenciaDAO` y sus tres JSP en `WEB-INF`.

## 4. Conexion JDBC como en la imagen de clase

La clase equivalente ya existe:
src/main/java/com/incluyelab/config/Conexion.java

Usa java.sql.Connection, java.sql.DriverManager y java.sql.SQLException.
Carga com.mysql.cj.jdbc.Driver y llama DriverManager.getConnection(url,user,password).
La base es portal_empleo_inclusivo. Los DAO invocan Conexion.getConnection(),
usan PreparedStatement y cierran conexiones mediante try-with-resources.
El conector MySQL 8.0.33 esta declarado en pom.xml.

La foto utiliza el nombre antiguo com.mysql.jdbc.Driver. El proyecto conserva
com.mysql.cj.jdbc.Driver, correspondiente a su conector, y no copia la cuenta root
ni la contrasena del ejemplo. La separacion por paquetes no cambia la funcion JDBC.

## 5. Filtros de adaptaciones, fase 1

Adaptaciones que necesitas:
- Accesibilidad fisica/motora: rampas, ascensores, escritorios regulables, perifericos.
- Apoyo visual: lectores NVDA/JAWS, macrotipos, contraste, teclados Braille.
- Comunicacion accesible: comunicacion escrita, subtitulos, interprete LSP.

Condiciones complementarias: horario flexible y pausas activas.
Teletrabajo se consulta por Modalidad: Remoto; no se confunde con horario flexible.

Las empresas y el administrador seleccionan apoyos especificos al publicar/editar.
Se guardan como codigos validados en ofertas.apoyos, aparte del texto descriptivo.
Un apoyo de una categoria hace que la oferta pertenezca a esa categoria.
Al seleccionar varias categorias, la oferta debe pertenecer a TODAS (AND).
Pertenecer a una categoria no significa contar con todos sus apoyos:
el detalle muestra los apoyos concretos para que el postulante los compruebe.
Sin apoyos seleccionados, una oferta sigue visible en la busqueda general,
pero no aparece como compatible con una adaptacion no declarada.
No se usan titulos de puestos ni diagnosticos para deducir compatibilidad.
Las declaraciones son de la empresa, no certificaciones medicas del portal.

Codigo:
- src/main/java/com/incluyelab/model/ApoyosOferta.java
- src/main/java/com/incluyelab/model/Oferta.java
- src/main/webapp/WEB-INF/jspf/apoyos-form.jspf
- src/main/webapp/index.jsp
- src/main/webapp/assets/js/app.js
- database/migrations/20261015_apoyos_ofertas.sql

La migracion agrega una columna sin borrar tablas ni registros. En su primera
aplicacion etiqueta solamente textos EXACTOS de las ofertas originales de demo,
y solo con los apoyos explicitamente descritos. No deduce LSP de una referencia
generica a lengua de senas, ni escritorio regulable de escritorio ergonomico.
Las demas ofertas requieren seleccion manual. Reejecutar la migracion no
sobrescribe selecciones posteriores. El instalador SQL tambien la incluye.

Fase 2 pendiente: empleo con apoyo/entornos estructurados y neurodivergencia.
Fase 3 pendiente: matching voluntario con preferencias guardadas del postulante.
No se presentan esas fases como implementadas.

## 6. Pruebas y limites

- tools/verify-portal.cjs: flujo publico, registro, login, publicacion y postulacion.
- tools/verify-admin.cjs: evidencia historica del CRUD anterior. Su flujo de alta de
  empresas ya no corresponde a la version actual; no usarlo para validar aprobaciones.
- tools/verify-sessions-supports.cjs: sesiones por rol, revocacion, filtros exactos,
  seleccion de apoyos desde empresa/admin y persistencia en MySQL.
- tools/verify-company-review.cjs: comprobacion de SOLO LECTURA del nuevo flujo,
  fichas, permisos GET y vistas adaptables. No registra empresas ni ofertas.
- Resultados JSON y capturas: verification/.
- tools/verify-password.cjs: cambio de clave para los tres roles, validaciones,
  CSRF, hash persistido, login con nueva clave y revocacion de otras sesiones.
  Usa solo cuentas temporales, sin crear empresas ni ofertas.

Las pruebas generan datos temporales y eliminan solamente sus propios registros.
La version es un proyecto academico local. Las claves nuevas (registro, admin y
perfil) usan PBKDF2-HMAC-SHA256 con 600000 iteraciones y sal aleatoria de 16 bytes.
Las cuentas antiguas conservan compatibilidad con su clave previa hasta cambiarla.
Antes de una publicacion real deben renovarse las claves demo/antiguas, configurar
HTTPS y agregar limites de intentos de autenticacion y recuperacion de cuenta.
Los favoritos/preferencias siguen locales al navegador, no sincronizados.
No se incluye carga de CV ni matching automatico.

## 7. Mi perfil y cambio de contrasena

Los tres roles acceden a /perfil desde la navegacion principal. La vista JSP esta
en WEB-INF y requiere sesion. Solicita clave actual, nueva (8 a 100 caracteres) y
confirmacion. El servlet toma el usuario exclusivamente de la sesion, valida CSRF
y no vuelve a mostrar los secretos al rechazar un formulario.

UsuarioDAO verifica la clave actual y guarda el hash en una transaccion con bloqueo
de fila. No necesita cambios en el esquema MySQL. Tras guardar, se invalida la
sesion y se redirige al login. SesionFilter compara la huella de la credencial con
MySQL en cada solicitud dinamica y revoca otras sesiones de esa cuenta.

Archivos: PerfilServlet.java, WEB-INF/perfil.jsp, UsuarioDAO.java, Passwords.java,
Usuario.java y SesionFilter.java. Las cuentas de demostracion no fueron alteradas.
## 8. Registro y aprobacion de empresas

- Registro de usuario Empresa y ficha pendiente en una transaccion.
- La empresa completa RUC, sector/tipo de negocio, presentacion, ano de inicio y logros.
- Administrador consulta la ficha, aprueba o rechaza con motivo obligatorio.
- Nueva ficha o edicion => pendiente; aprobacion => visible; rechazo => correccion y reenvio.
- Solo empresas aprobadas con cuenta activa publican ofertas o aparecen con ficha publica.
- Las ofertas existentes se ocultan si su empresa vuelve a pendiente; no se borran.
- Las postulaciones a ofertas no disponibles tambien se rechazan en el DAO.
- Revision y edicion usan CSRF, rol/sesion y numero de version para evitar decisiones obsoletas.
- No se interpreta aprobacion como certificacion de inclusion o representacion legal.
- No se inventaron fechas, presentaciones ni logros de marcas: los campos sin datos
  quedan por completar por la empresa.
- Migracion: database/migrations/20261016_revision_empresas.sql. Agrega columnas;
  las empresas demo preexistentes conservan visibilidad como aprobadas importadas.
  Reejecutar la migracion no cambia decisiones posteriores.

Verificacion actual: compilacion y pruebas de lectura pasaron; 11 ofertas originales
continuan visibles. Por solicitud del usuario NO se ejecuto la prueba de escritura
(registro, envio, aprobacion/rechazo, publicacion). No se crearon datos temporales.

