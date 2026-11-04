# Portal de Empleo Inclusivo

## Version actual (31 de octubre de 2026)

Esta carpeta es la base oficial del proyecto. Incluye la web publica JDBC,
accesibilidad, cinco roles, verificacion CONADIS manual, correo OTP, perfiles,
ofertas, postulaciones, Recursos Humanos, Soporte Tecnico y administracion.

La explicación funcional, el alcance implementado y las comprobaciones manuales
se encuentran en `docs/ACCESIBILIDAD.md`. Esta entrega conserva los flujos de
CONADIS, verificación de correo OTP, perfiles, ofertas, postulaciones, Recursos
Humanos, Soporte Técnico y administración existentes.

Proyecto web Java desarrollado para NetBeans con JSP, Servlets, JavaBeans, DAO y MySQL.

## Tema

Portal Web de Empleo Inclusivo para la reduccion de desigualdades laborales, alineado al ODS 10.

## Roles actuales

- Administrador Central (`ADMIN` en el codigo): crea cuentas internas, administra
  usuarios y consulta la auditoria general. Empresas, ofertas y postulaciones se
  muestran en modo consulta; sus propietarios conservan la gestion.
- Postulante: gestiona su perfil y CV, consulta ofertas, postula, retira sus propias
  postulaciones y consulta notificaciones. Para postular necesita CONADIS aprobado.
- Empresa: completa su ficha, publica y administra sus ofertas y revisa candidatos
  de sus propias convocatorias.
- Recursos Humanos: revisa CONADIS y administra evaluaciones de seleccion.
- Soporte Tecnico: atiende incidencias, verifica identidad, desbloquea cuentas y
  genera claves temporales sin consultar la contrasena anterior.

## Usuarios de prueba

- Administrador: `admin@incluyelab.pe` / `123456`
- Empresa: `empresa@incluyelab.pe` / `Empresa#2026`
- Postulante: `sofia@correo.com` / `123456`
- Recursos Humanos: `marco.salcedo@incluyelab.com` / `Minecraft4.exe`
- Soporte Tecnico: `daniel.advincula@incluyelab.com` / `Minecraft5.exe`

## Instalacion de la base de datos

Para una computadora nueva, abrir MySQL Workbench con una cuenta administradora y
ejecutar completo:

```sql
database/portal_empleo_inclusivo.sql
```

Luego ejecutar la migracion de procedimientos almacenados requerida por T2:

```sql
database/migrations/20261104_crud_stored_procedures.sql
```

Para actualizar una base anterior sin borrar sus registros, ejecutar una sola vez:

```sql
database/actualizar_version_actual.sql
```

Despues ejecutar tambien `database/migrations/20261104_crud_stored_procedures.sql`.

Despues ejecutar `database/verificar_instalacion.sql`. El resultado debe mostrar
`INSTALACION_COMPLETA`. No se deben ejecutar manualmente todas las migraciones
historicas; permanecen en `database/migrations` solo como historial tecnico.

La conexion por defecto usa:

- Base de datos: `portal_empleo_inclusivo`
- El instalador crea el usuario local de desarrollo `incluyelab_app`.
- En el equipo principal no existe un `Resource` de Tomcat: se utiliza el archivo
  externo `%USERPROFILE%\IncluyeLab\db.properties`.
- Orden de conexion: `jdbc/IncluyeLab` real de Tomcat; variables o propiedades JVM
  `DB_URL`, `DB_USER`, `DB_PASSWORD`; archivo externo `db.properties`.
- Si JNDI no existe o el pool no puede abrir una conexion, se usa automaticamente
  la configuracion externa. `web.xml` no declara un `resource-ref`, evitando que
  Tomcat construya un `BasicDataSource` vacio.
- El ejemplo sin secretos esta en `database/db.properties.example`.

Configuracion recomendada para desarrollo en otra computadora:

```properties
DB_URL=jdbc:mysql://localhost:3306/portal_empleo_inclusivo?useSSL=false&serverTimezone=America/Lima&allowPublicKeyRetrieval=true
DB_USER=incluyelab_app
DB_PASSWORD=CLAVE_CONFIGURADA_EN_MYSQL
```

JNDI sigue siendo opcional. Si el equipo lo utiliza, puede declarar en
`conf/context.xml` de Tomcat un recurso como este y colocar el driver MySQL en
`$CATALINA_HOME/lib`:

```xml
<Resource name="jdbc/IncluyeLab"
          auth="Container"
          type="javax.sql.DataSource"
          factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
          driverClassName="com.mysql.cj.jdbc.Driver"
          url="jdbc:mysql://localhost:3306/portal_empleo_inclusivo?useSSL=false&amp;serverTimezone=America/Lima&amp;allowPublicKeyRetrieval=true"
          username="USUARIO_MYSQL"
          password="CLAVE_MYSQL"
          maxActive="20"
          maxIdle="5"
          maxWait="10000"/>
```

No se necesita volver a agregar `resource-ref` a `web.xml`: un `Resource`
declarado en el contexto de Tomcat se publica en `java:comp/env`.

La guia completa para otra computadora esta en `docs/INSTALACION_WINDOWS.md`.

## Abrir en NetBeans

1. Abrir Apache NetBeans.
2. Ir a `File > Open Project`.
3. Seleccionar la carpeta `Portal_Empleo_Inclusivo`.
4. Ejecutar `Clean and Build`.
5. Correr el proyecto con Apache Tomcat 9.

## Rutas principales

- `/inicio`: pagina publica con ofertas.
- `/login`: inicio de sesion.
- `/registro`: registro de usuarios con inicio de flujo OTP.
- `/verificar-correo`: verificacion de direccion de correo mediante codigo OTP de 6 digitos.
- `/verificacion-conadis`: flujo de verificacion de identidad digital con carnet CONADIS para postulantes.
- `/conadis-foto`: visor seguro de carnet CONADIS para su titular y Recursos Humanos.
- `/revision-conadis`: revision, aprobacion, rechazo o vencimiento exclusivo de Recursos Humanos.
- `/postulante`: panel del postulante (requiere verificacion CONADIS aprobada).
- `/empresa`: panel de empresa.
- `/admin`: panel administrador.
- `/recursos-humanos`: CRUD de evaluaciones de candidatos.
- `/soporte-tecnico`: CRUD de incidencias asignadas.
- `/soporte`: formulario publico para reportar una incidencia.

## Flujo de Verificacion de Identidad Digital (CONADIS)

- Los postulantes, tras autenticarse con correo y contraseña, deben validar su carnet de inscripción CONADIS para acceder a las ofertas inclusivas y postular.
- El postulante registra RUI y fotografia; la solicitud inicia en `PENDIENTE`.
- No existe un padron ficticio ni aprobacion automatica.
- Recursos Humanos revisa manualmente la solicitud y puede marcarla `APROBADA`,
  `RECHAZADA` o `VENCIDA`. El rechazo exige motivo y permite reenvio.
- Mientras no este aprobada, el postulante puede consultar y corregir su solicitud,
  pero no puede postular a ofertas.
- La fotografia se guarda fuera de recursos publicos y se entrega mediante un
  servlet protegido. Los cambios de estado se conservan en un historial.
- **Protección y Privacidad**:
  - Se cumple el principio de minimización de datos (Ley 29733): no se solicita diagnóstico médico (CIE-10) ni tipo de discapacidad en la verificación.
- La estructura vigente esta incluida en el instalador y en la actualizacion consolidada.
- El instalador incluye dos expedientes demostrativos protegidos: Sofia (`RD406923`)
  y Luis (`RD406924`). Sus carnets y CV se almacenan bajo `WEB-INF/demo`, por lo
  que no son descargables como recursos publicos; se sirven unicamente mediante
  los controladores autorizados. Estos registros son datos de simulacion academica
  revisados manualmente y no representan una consulta oficial en linea.
- Para una base antigua ya instalada, crear primero un respaldo y ejecutar
  `database/migrations/20261103_actualizar_reglas_conadis.sql`; despues ejecutar
  `database/migrations/20261103_postulantes_demo_conadis_cv.sql`. Una instalacion
  nueva solo necesita el script consolidado principal.

## Flujo de Verificación de Correo por Código OTP (Email Verification Flow)

- **Propósito**: Garantizar la autenticidad del correo electrónico registrado y prevenir cuentas fantasmas o no autorizadas.
- **Mecanismo de Seguridad**:
  - Al registrarse una cuenta, se crea un código OTP numérico de 6 dígitos mediante `java.security.SecureRandom`.
  - Solo se almacena el hash PBKDF2 del código en `codigos_otp`, con vigencia de 15 minutos y límite de 5 intentos.
- **Ruta y Experiencia de Usuario**:
  - `/verificar-correo`: Interfaz con 6 casillas numéricas con avance automático al escribir, soporte para pegar (Ctrl+V) y temporizador de expiración.
  - El código se entrega al correo mediante SMTP y nunca se muestra ni se autocompleta en la web. Configura `MAIL_HOST`, `MAIL_PORT`, `MAIL_USER`, `MAIL_PASSWORD`, `MAIL_FROM` y, opcionalmente, `MAIL_STARTTLS` en Tomcat o en el entorno.
  - **Control de Acceso**: `SesionFilter` y `LoginServlet` exigen la validación del correo (`correo_verificado = 1`) antes de permitir el acceso al resto de las funciones del sistema.
- La tabla OTP vigente forma parte del instalador y de la actualizacion consolidada.

## CRUD de Recursos Humanos y Soporte Tecnico

Los cinco CRUD evaluables de T2 (cuentas internas, ofertas, postulaciones,
evaluaciones de RR. HH. e incidencias de Soporte) utilizan 23 Stored Procedures
invocados desde JDBC mediante `CallableStatement`. La migracion es
`database/migrations/20261104_crud_stored_procedures.sql`.

- Recursos Humanos puede crear, consultar, editar y eliminar sus evaluaciones en borrador.
  Las evaluaciones publicadas conservan el historial y ya no se eliminan.
- Soporte Tecnico puede crear, consultar, editar y eliminar incidencias internas pendientes.
  Las solicitudes externas se aceptan o rechazan y se actualizan hasta quedar resueltas.
- Ambos paneles tienen control de sesion por rol, tokens CSRF y consultas preparadas JDBC.
- El administrador puede crear, editar, activar o desactivar las cuentas internas.
- Las tablas vigentes forman parte de `database/actualizar_version_actual.sql`.

## Composicion del perfil del postulante

`Experiencia`, `Educacion` y `Certificacion` son clases internas `static final`
de `PerfilPostulante`; no existen como archivos Java independientes. Sus tres
colecciones se crean junto con cada perfil y siempre estan disponibles, incluso
cuando todavia no contienen registros. El DAO agrega los datos mediante los metodos
de composicion del perfil. Para el diagrama de clases usar
`docs/diagrama_clases_perfil.puml` y mantener las tres clases dentro del mismo bloque.

## Interfaz actualizada

La portada mantiene la carga de ofertas desde MySQL y agrega busqueda por texto y ubicacion,
filtros por modalidad, empresa y adaptaciones, orden por salario/titulo, y detalle de cada oferta.
Los formularios de registro, ingreso, publicacion y postulacion usan los Servlets y DAO existentes.

- Preferencias de contraste, fuente legible y texto ampliado: guardadas en el navegador.
- Ofertas guardadas: solo en ese navegador, no en la cuenta MySQL.
- Cuentas, ofertas publicadas y postulaciones: persistentes en MySQL.
- Los 23 logos, las fuentes y los iconos se sirven desde `src/main/webapp/assets`.
- El directorio incluye empresas sin ofertas; seleccionarlas muestra el estado sin resultados.
- Las vacantes de demostracion no son convocatorias oficiales de las marcas mostradas.

Archivos de presentacion: `src/main/webapp/*.jsp`, `WEB-INF/jspf`, `assets/css/styles.css`
y `assets/js/app.js`. Los includes compartidos conservan UTF-8 para los textos en espanol.

## Verificacion

`tools/verify-portal.cjs` prueba con Playwright la busqueda, filtros, guardadas, detalle,
accesibilidad y vistas de 390, 768 y 1440 px. Con `PORTAL_DB_PASSWORD`, tambien crea
cuentas temporales de empresa y postulante, publica una oferta, registra una postulacion,
verifica sus filas en MySQL y elimina exclusivamente los datos creados por esa ejecucion.
Necesita Microsoft Edge, Playwright (`PLAYWRIGHT_MODULE`) y MySQL CLI (`MYSQL_EXE`).
El ingreso administrativo de prueba puede configurarse con `PORTAL_ADMIN_PASSWORD`.
Los resultados y capturas quedan en `verification/`.

## Bootstrap y administracion

Bootstrap 5.3.8 esta integrado localmente en `assets/vendor`, sin depender de un CDN
para navegar. `WEB-INF/jspf/head.jspf` lo carga antes del tema del portal.
Los formularios utilizan `form-control` y `form-select`; las pantallas de empresa y
administracion usan la grilla `row`, `col-md-6` y `col-12`. Las tablas utilizan
`table-responsive`, `table-hover` y `align-middle`; los avisos administrativos
usan el componente Alert de Bootstrap con cierre interactivo.

- Usuarios: crear cuentas internas y editar datos, rol interno y estado. Una
  contrasena vacia al editar conserva la actual. El administrador no puede
  desactivar su propia cuenta ni modificar cuentas empresariales.
- Empresas: registro propio y aprobacion/rechazo administrativo. Ya no hay alta
  de empresas desde el administrador; sus responsables completan la ficha.
- Ofertas: el administrador solo consulta; cada empresa administra las propias.
- Postulaciones: el administrador solo consulta; el postulante y la empresa actuan
  dentro de sus permisos y sobre registros propios.
- Todas las escrituras requieren POST, sesion de administrador activo y token CSRF.
  El servidor valida los datos y las claves foraneas protegen el historial relacionado.
  Abrir la confirmacion o pulsar Cancelar no elimina informacion.

Implementacion: `AdminServlet.java`, `AdminDAO.java`, `admin.jsp` y
`WEB-INF/admin-form.jsp`. Se mantiene la arquitectura JSP, Servlets, JavaBeans,
DAO y MySQL. Para una base anterior se usa exclusivamente la actualizacion
consolidada; no se vuelve a importar el instalador con datos de demostracion.

`tools/verify-admin.cjs` corresponde al flujo anterior de cuatro CRUD mediante el navegador
y SELECT en MySQL, validaciones, permisos, CSRF, cancelacion y dependencias.
Tambien captura el panel y formularios a 390, 768 y 1440 px y en alto contraste.
Usa las mismas variables que `verify-portal.cjs`; requiere `PORTAL_DB_PASSWORD`.
Las pruebas limpian exclusivamente sus propios registros temporales.
Resultados: `verification/admin-results.json`.

## Sesiones y filtros (15 de octubre de 2026)

El control comun en `SesionFilter` protege paneles y JSP por rol, revalida
cuentas activas y revoca sesiones ante cambios de rol/estado. El login renueva
la sesion; el timeout es de 30 minutos. Las respuestas dinamicas no se almacenan
en cache y la cookie de sesion es HttpOnly.

Las adaptaciones se seleccionan explicitamente al crear/editar ofertas y se
guardan en `ofertas.apoyos`. La busqueda ya no infiere apoyos por palabras del
titulo o la descripcion. La fase 1 comprende fisica, visual y auditiva;
horario flexible/pausas son complementos y Remoto es una modalidad.
Las fases 2 y 3 siguen pendientes.

Para actualizar una instalacion anterior ejecutar
`database/actualizar_version_actual.sql`. Para una base nueva usar
`database/portal_empleo_inclusivo.sql`.

### Detalle profesional de ofertas

Las ofertas muestran una ficha ampliada con funciones, formacion, experiencia,
conocimientos tecnicos y condiciones laborales. Los datos de demostracion ya
estan incluidos en el instalador principal.

La descripcion admite encabezados con `##` y listas con `-`, formato que las
empresas pueden completar desde su panel al publicar una oportunidad.

Evidencia tecnica y recorrido por archivos: `docs/VERIFICACION_RUBRICA.md`.
Prueba adicional: `tools/verify-sessions-supports.cjs`, con las mismas variables
de entorno de las otras pruebas. Resultados en `verification/sessions-supports-results.json`.

## Recursos visuales

El directorio incluye 23 marcas reales: empresas con presencia en Peru y referencias
internacionales identificadas como tales. Se incorporaron Microsoft, Amazon, Walmart,
Mercado Libre, Falabella, SAP, ACCIONA, Clinica Internacional, Clinica San Pablo Surco
y Pardos Chicken. Cada ficha enlaza al sitio oficial y al filtro de ofertas del portal.
No se inventan convocatorias ni cuentas de acceso para estas marcas.
La cuenta de empresa demo original conserva su correo y clave, y ahora usa Microsoft
como marca de referencia (no es una cuenta real de esa empresa). Las ofertas del
prototipo se identifican como demostrativas.

El directorio publico se obtiene mediante JDBC desde `empresas` y `ofertas`.
`DirectorioEmpresas.java` ya no es la fuente principal de datos.
Los diez logos nuevos provienen de sitios oficiales; sus URLs estan en sources.json.
`tools/download-company-logos.cjs` permite descargarlos de nuevo.
La normalizacion de empresas de demostracion esta incluida en el instalador.

- Referencia de experiencia: Evenbreak, https://www.evenbreak.co.uk/
- Logos: sitios oficiales de las empresas y archivos de Wikimedia Commons.
  Las direcciones originales estan en `src/main/webapp/assets/logos/sources.json`.
- Iconos: Lucide 0.468.0 (ISC). Fuentes: Ubuntu y Atkinson Hyperlegible, via Google Fonts.
- Bootstrap 5.3.8 (MIT): https://getbootstrap.com/docs/5.3/getting-started/introduction/
- `tools/download-assets.cjs` permite volver a descargar los recursos; no se ejecuta al navegar.

## Cambiar la contrasena desde Mi perfil

Todos los roles autenticados tienen el enlace **Mi perfil** en el menu.
Desde `/perfil` ingresan la clave actual, una nueva de 8 a 100 caracteres y su
confirmacion. El cambio se guarda en MySQL; luego deben iniciar sesion nuevamente.
Las otras sesiones de la misma cuenta se revocan en su siguiente solicitud.

Todas las claves, incluidas las cuentas académicas incluidas en el instalador, se
almacenan con PBKDF2-HMAC-SHA256, 600000 iteraciones y sal aleatoria. La actualización
consolidada migra las credenciales de demostración que aún estén en texto plano.

Prueba automatizada: `tools/verify-password.cjs` (requiere `PLAYWRIGHT_MODULE` y
`PORTAL_DB_PASSWORD`). Usa cuentas temporales que elimina al terminar, sin crear
empresas ni ofertas. Evidencia: `verification/password-results.json` y capturas
`verification/perfil-*.png`.
## Solicitudes de empresas y ficha publica

1. La empresa crea su cuenta en Registro, con rol Empresa.
2. En Mi panel abre Editar presentacion y completa su ficha.
3. El administrador abre Solicitudes de empresas > Revisar solicitud.
4. Aprueba o rechaza indicando observaciones. La empresa consulta el resultado en su panel.
5. Al aprobarse puede publicar ofertas. Editar la ficha exige nueva revision y oculta
   sus ofertas mientras esta pendiente, sin borrarlas.

El perfil publico muestra presentacion, sector, ano de inicio, trayectoria calculada
por ano y logros/metas cumplidas. Los campos antiguos sin informacion no se inventan.
Los logos existentes se mantienen. Las marcas del directorio tambien tienen enlace
a su ficha de referencia; no implica que esten registradas ni tengan convenios.

La estructura de revision empresarial esta incluida en ambos scripts oficiales.
Las empresas previas conservan sus datos; las nuevas quedan pendientes.

Comprobacion de solo lectura: `tools/verify-company-review.cjs`.
Resultados: `verification/company-review-results.json`.
Por indicacion del usuario, NO se crearon empresas/ofertas ni se ejecutaron pruebas
de escritura de este flujo. Compilacion, pantallas y permisos GET comprobados.

## Recursos Humanos, seguridad y soporte

Recursos Humanos puede revisar los CV y perfiles de postulantes de todas las empresas,
registrar puntajes de CV, entrevista, desempeno y compatibilidad, emitir un veredicto
y dejar retroalimentacion. Soporte clasifica casos de seguridad, acceso, infracciones
y fallas tecnicas; atiende cuentas comprometidas y puede desbloquear una cuenta o generar una clave temporal despues de
aceptar el caso. Nunca puede consultar la contrasena anterior, y la clave temporal obliga
al usuario a definir una nueva al ingresar.

El portal no incluye planes, suscripciones, pagos ni facturacion. El modulo de Seguridad
y reportes permite gestionar denuncias por perfiles falsos, spam, acoso y contenido que
incumpla las normas de la comunidad, dejando decision, estado y solucion documentados.

La actualizacion consolidada incorpora Recursos Humanos y Soporte Tecnico y retira
los restos del prototipo de suscripciones.

### Evaluaciones y eliminaciones por propietario

Las evaluaciones de Recursos Humanos se relacionan con la postulacion, la oferta y su
empresa. Cuando RR. HH. marca una evaluacion como `PUBLICADO`, la empresa propietaria
puede verla en su panel y dentro del perfil del candidato; los borradores siguen siendo
internos. La empresa puede eliminar sus propias postulaciones y ofertas. Al eliminar una
oferta se eliminan tambien sus postulaciones y evaluaciones relacionadas, previa
confirmacion. El postulante puede eliminar unicamente sus propias postulaciones. Todas
estas acciones validan rol, propiedad y token CSRF en el servidor.

### Notificaciones internas

La empresa puede pasar una postulacion a revision, admitirla o eliminarla; la opcion
de rechazo empresarial fue retirada. Cuando elimina una postulacion, el postulante
recibe una notificacion interna. Si elimina una oferta, se notifica a todos sus
postulantes antes de borrar las postulaciones y evaluaciones relacionadas.

El formulario de Seguridad y reportes solicita el correo de contacto. Al enviarlo,
la incidencia y una notificacion se asignan automaticamente a una cuenta activa de
Soporte Tecnico. El correo identifica la cuenta afectada y queda visible para el
seguimiento dentro del portal; no se usa un servicio SMTP externo.

Las notificaciones forman parte de los dos scripts oficiales de base de datos.

