# Guía para corregir el feedback de auditoría

Fecha: 4 de noviembre de 2026.

Este documento es un plan de implementación y validación para la computadora donde está MySQL. No certifica que las correcciones ya estén implementadas ni que la base instalada coincida con los scripts del repositorio.

## 1. Preparación

1. Abrir este repositorio en la computadora que tiene acceso a MySQL.
2. Revisar `git status` y conservar cualquier trabajo local antes de actualizar el código. Crear una rama, por ejemplo `fix/auditoria-crud`.
3. Leer las instrucciones locales que existan en `AGENTS.md`, el `README.md` y la configuración real de conexión en `src/main/java/com/incluyelab/config/Conexion.java`. No publicar contraseñas, archivos de configuración privados ni volcados con datos personales.
4. Identificar la base y versión de MySQL utilizadas por la aplicación. Comparar sus tablas, columnas, claves foráneas, triggers y procedimientos con los scripts de `database/`. No asumir que todos los scripts históricos deban ejecutarse.
5. Obtener un respaldo de la base con procedimientos y triggers y comprobar que se puede restaurar. Hacer las pruebas de escritura en una copia de la base. Los instaladores pueden contener instrucciones destructivas; leerlos antes de ejecutarlos.
6. Registrar el estado inicial: compilación, listado de procedimientos y comportamiento de los tres paneles afectados.

Desde PowerShell, dentro del repositorio:

```powershell
git status --short --branch
git switch -c fix/auditoria-crud
java -version
mvn -version
mvn clean verify
```

El proyecto declara Java 11 y genera un WAR. Utilizar el servidor compatible con `javax.servlet` configurado para el proyecto. `mvn clean verify` por sí solo no demuestra que funcionen los flujos web ni los procedimientos.

## 2. Prioridad alta: mensajes de negocio que terminan en 503

### Archivos iniciales

- `src/main/java/com/incluyelab/servlet/RecursosHumanosServlet.java`
- `src/main/java/com/incluyelab/servlet/SoporteTecnicoServlet.java`
- `src/main/java/com/incluyelab/servlet/AdminServlet.java`
- Sus DAO y vistas JSP correspondientes.
- `database/migrations/20261104_crud_stored_procedures.sql`

### Cambios

1. Revisar los `catch (SQLException)` de las operaciones de escritura. Actualmente convierten rechazos de los procedimientos en errores 503.
2. Distinguir los rechazos controlados que los procedimientos emiten con `SIGNAL SQLSTATE '45000'` de los errores técnicos. Revisar también la cadena `getNextException()` si el controlador JDBC envuelve la excepción.
3. Centralizar esta clasificación en una utilidad pequeña o traducir estos rechazos a una excepción de negocio en la capa DAO. Evitar copiar la misma lógica en cada servlet.
4. Mostrar únicamente el mensaje del rechazo controlado en el panel o formulario, con estado 400 o 409 según corresponda. No mostrar mensajes JDBC arbitrarios ni trazas SQL.
5. Para fallos técnicos, registrar el detalle en el servidor y mostrar un mensaje genérico. Reservar 503 para indisponibilidad; no clasificar cualquier fallo SQL como indisponibilidad.
6. Revisar los errores ya capturados como `IllegalArgumentException`: en Admin, `sendError` puede enviar a una página de error y perder la experiencia del panel. Usar una vista con mensaje o aviso de sesión que se consuma una sola vez.
7. Si se usa redirección, transportar el aviso mediante sesión y borrarlo al leerlo. Si se hace `forward`, recargar los datos necesarios sin perder el error ni sobrescribir el estado HTTP. Nunca reenviar contraseñas a la vista.
8. Verificar que el JSP escape el texto del mensaje y mantenga intactos los controles de rol, titularidad y CSRF.

### Pruebas obligatorias

| Caso | Resultado esperado |
| --- | --- |
| RR. HH. intenta eliminar evaluación ajena o fuera de borrador | Mensaje de negocio claro; registro intacto; sin 503 |
| Soporte intenta eliminar incidencia no permitida | Mensaje claro; incidencia e historial intactos |
| Admin intenta desactivar cuenta ya inactiva | Mensaje claro; sin 503 |
| Operación válida de cada panel | Se completa y muestra confirmación |
| Error técnico de conexión en entorno de prueba | Mensaje genérico y detalle en log; sin exponer credenciales |
| Solicitud sin rol o con CSRF incorrecto | Rechazo; sin modificación |

## 3. Prioridad alta: borrado real de cuentas desde Admin

### Situación observada

`sp_usuario_eliminar` existe en la migración y ejecuta un `DELETE FROM usuarios`. `AdminServlet` acepta `guardar` y `dar_baja`. La baja lógica y el borrado definitivo deben tener acciones y textos distintos.

### Revisión previa del modelo

1. Inspeccionar en la base real todas las claves foráneas que apuntan a usuarios, sus reglas `ON DELETE` y los triggers. Revisar también dependencias indirectas y referencias sin clave foránea.
2. Identificar qué ocurriría con empresas, ofertas, postulaciones, evaluaciones, incidencias, verificaciones y auditorías al borrar una cuenta.
3. Definir y documentar qué cuentas se pueden borrar. Mantener las restricciones existentes de Admin; impedir el borrado de la propia cuenta y proteger al último administrador activo. Revisar estas condiciones también en las rutas existentes.
4. Para cuentas con historial que debe conservarse, rechazar el borrado con mensaje claro y ofrecer la desactivación. No habilitar cascadas generales para conseguir que pase una prueba CRUD.
5. Si el procedimiento necesita nuevas validaciones, preparar una migración adicional que las incorpore y mantener consistente la instalación nueva. Las comprobaciones y el borrado deben ser atómicos; revisar concurrencia y bloqueo, especialmente para el último administrador.

### Implementación

1. Revisar `src/main/java/com/incluyelab/dao/AdminDAO.java` y reutilizar sus controles de autorización y transacciones.
2. Agregar un método explícito para eliminar que invoque `sp_usuario_eliminar` mediante `CallableStatement`, sin concatenar parámetros.
3. Aceptar una acción POST `eliminar` en `AdminServlet`, validar ID positivo, sesión, rol y CSRF y dirigirla al método nuevo.
4. Incorporar un botón separado en `src/main/webapp/admin.jsp` o en la vista real de cuentas. Explicar el efecto y pedir confirmación al usuario antes de enviar el formulario. La confirmación visual no sustituye los controles del servidor.
5. Mantener `dar_baja` como operación independiente. Usar avisos diferentes: cuenta desactivada frente a cuenta eliminada.
6. Traducir las restricciones referenciales esperadas a mensajes comprensibles sin mostrar la excepción SQL completa.

### Pruebas

- Crear una cuenta temporal elegible y eliminarla desde la web; comprobar su ausencia con una consulta de lectura.
- Intentar borrar una cuenta con historial protegido y confirmar el rechazo sin pérdida de registros.
- Probar ID inexistente, propia cuenta, último administrador y cuenta fuera del alcance autorizado.
- Probar petición manipulada y CSRF incorrecto.
- Verificar que la desactivación sigue conservando el historial y bloqueando el acceso según las reglas existentes.
- No usar cuentas reales para estas pruebas.

## 4. Prioridad media: cierre de ofertas y mensaje incorrecto

### Archivos y cambios

1. Revisar `src/main/java/com/incluyelab/servlet/OfertaServlet.java`, el DAO de ofertas y las vistas que envían esa acción.
2. Confirmar en la base real que la operación cambia el estado a `cerrada` y conserva las postulaciones.
3. Sustituir la confirmación que indica que fueron eliminadas por: **“Oferta cerrada. Las postulaciones se conservan.”**
4. Cambiar los botones y confirmaciones visibles a “Cerrar oferta”. Se puede conservar el nombre interno de la acción si cambiarlo implica compatibilidad innecesaria; si se renombra, actualizar todos sus consumidores.
5. Alinear README y documentos de rúbrica: indicar cierre lógico. Si la evaluación exige borrado físico de ofertas, tratarlo como un requisito adicional explícito; un cambio de texto no lo implementa.

### Pruebas

- Cerrar una oferta de prueba propia y comprobar que su fila sigue existiendo con estado `cerrada`.
- Confirmar que el número y contenido de sus postulaciones se conserva.
- Verificar que deja de admitir nuevas postulaciones y que la visibilidad pública corresponde a las reglas del portal.
- Probar cierre repetido y cierre de oferta ajena; ambos deben mostrar el rechazo esperado.

## 5. Prioridad media: instalación y actualización de procedimientos

### Archivos

- `database/portal_empleo_inclusivo.sql`
- `database/actualizar_version_actual.sql`
- `database/migrations/20261104_crud_stored_procedures.sql`
- `database/verificar_instalacion.sql`
- `README.md`

### Cambios

1. Separar claramente la instalación en una base vacía de la actualización de una base existente. Nunca ejecutar el instalador de tablas sobre la base con datos para arreglar solo procedimientos.
2. Hacer que el flujo principal documentado de instalación cree también todos los procedimientos requeridos. Preferir que el archivo principal sea autosuficiente si se importa desde Workbench; `SOURCE` depende del cliente y de la ruta y no funciona igual en todos los importadores.
3. Mantener sincronizadas las definiciones de instalación nueva y migración, o proporcionar un generador reproducible y comprobar su salida para evitar divergencias.
4. Para la base existente, revisar primero compatibilidad de columnas y procedimientos; aplicar únicamente las migraciones necesarias. Los `DROP PROCEDURE` y `CREATE PROCEDURE` no se deshacen con un simple `ROLLBACK`.
5. Documentar cliente, orden de ejecución y permisos necesarios para crear y ejecutar rutinas. No agregar `DEFINER` con una cuenta personal.
6. Validar la instalación desde cero en una base aislada y la actualización en una copia representativa de la base actual. Antes de importar, revisar todos los `USE` y nombres fijos para evitar apuntar a la base original.

## 6. Verificación por nombres, no por cantidad

`database/verificar_instalacion.sql` acepta actualmente 23 procedimientos cuyo nombre coincida con `sp_%`. Eso puede aprobar una instalación que tenga rutinas equivocadas.

1. Extraer de los DAO las llamadas realmente requeridas y contrastarlas con la migración. La migración actual contiene estos 23 nombres:

```text
sp_usuario_listar
sp_usuario_crear_interno
sp_usuario_actualizar_interno
sp_usuario_eliminar
sp_usuario_desactivar
sp_oferta_listar_empresa
sp_oferta_listar_todas
sp_oferta_crear
sp_oferta_actualizar
sp_oferta_cerrar
sp_postulacion_listar
sp_postulacion_crear
sp_postulacion_actualizar_empresa
sp_postulacion_eliminar_usuario
sp_postulacion_eliminar_empresa
sp_evaluacion_listar
sp_evaluacion_crear
sp_evaluacion_actualizar
sp_evaluacion_eliminar
sp_incidencia_listar
sp_incidencia_crear_interna
sp_incidencia_actualizar
sp_incidencia_eliminar
```

2. Reemplazar la condición de cantidad por una lista explícita y verificar cada nombre en `information_schema.routines`, con `routine_schema=DATABASE()` y `routine_type='PROCEDURE'`.
3. Mostrar exactamente cuáles faltan y hacer que el resumen final use los mismos requisitos, sin conservar la comprobación antigua por cantidad en otra sección.
4. Agregar a esa lista cualquier procedimiento nuevo que se introduzca para las consultas públicas o incidencias externas.
5. Para mayor cobertura, verificar firma, cantidad, orden y modos de parámetros con `information_schema.parameters` o ejecutar llamadas controladas en la base de prueba. La presencia del nombre no garantiza una implementación correcta.
6. Probar en la copia: instalación completa; una rutina requerida ausente; rutinas adicionales que no deben compensar la ausencia. Restaurar la copia después.

## 7. SQL directo pendiente y código sin uso

1. Inventariar consultas de `src/main/java/com/incluyelab/dao/`, especialmente el listado público de ofertas y `IncidenciaDAO.registrarExterna`.
2. Determinar el alcance de la rúbrica. SQL preparado directo no constituye por sí solo un defecto de seguridad; si se exige usar procedimientos para estas operaciones, migrarlas también.
3. Crear los procedimientos necesarios en una migración y en la instalación principal. Mantener filtros, orden, campos devueltos, aprobación de empresas, estado de cuentas, validaciones y límites actuales.
4. Conservar el envío de incidencias externas por usuarios sin sesión si ese es el comportamiento previsto; no copiar sin revisión el control de rol de la creación interna.
5. Actualizar los DAO con parámetros enlazados y cierre de recursos. Añadir los procedimientos al verificador y probar la consulta pública y el alta externa.
6. Identificar código sin uso comprobando referencias Java, JSP, anotaciones de servlets, `web.xml`, configuración, scripts y usos por reflexión. No borrar una clase solo porque no tenga referencias Java directas.
7. Retirar únicamente código confirmado como innecesario y compilar nuevamente.

## 8. Evidencias y documentación reproducibles

1. Revisar `docs/VERIFICACION_RUBRICA.md`, README y las carpetas `tools/` y `verification/`.
2. Localizar la afirmación de una prueba transaccional CRUD y comprobar si su script existe y es ejecutable. No dar por válida una prueba por estar descrita o tener una captura.
3. Incorporar el script faltante con instrucciones, requisitos, configuración por entorno y limpieza de sus propios datos temporales; o retirar la afirmación y marcar esa validación como pendiente.
4. No afirmar que una compilación prueba las JSP desplegadas o que una prueba DAO cubre el servlet, los permisos y CSRF. Registrar cada nivel por separado.
5. Mantener una tabla de evidencia: caso, comando o pasos reproducibles, resultado, fecha y entorno. No incluir secretos ni datos personales.
6. Las pruebas deben utilizar identificadores de sus propios registros y limpieza acotada. No ejecutar borrados amplios. No confiar solo en rollback si el flujo web abre otras conexiones o si el script ejecuta DDL.

## 9. Validación y entrega

Orden recomendado:

1. Preparar copia de base y registrar el estado inicial.
2. Corregir mensajes y cerrar la discrepancia del texto de ofertas.
3. Revisar dependencias y completar el borrado de cuentas con sus protecciones.
4. Unificar instalación, actualización y verificador.
5. Resolver SQL pendiente según el alcance de la auditoría y limpiar código confirmado.
6. Completar evidencia y documentación.
7. Ejecutar `mvn clean verify`, desplegar el WAR generado y realizar las pruebas web y SQL anteriores en la copia.
8. Revisar `git diff --check`, `git diff --stat` y el diff completo. Confirmar que no hay credenciales, respaldos ni cambios accidentales.
9. Entregar código, migraciones, guía de instalación y resultados reproducibles. Identificar cualquier caso no ejecutado y su motivo.
10. Para aplicar en la base real: respaldo verificado, pausa de escrituras si corresponde, migración revisada, despliegue compatible y comprobaciones de lectura. Ante un fallo de DDL, usar un script de reversión revisado o restauración verificada; no asumir que el rollback revierte procedimientos.

### Criterios de aceptación

- [ ] Los rechazos de negocio llegan a la interfaz con un mensaje claro y sin 503.
- [ ] Los errores técnicos no exponen SQL, credenciales ni trazas al usuario.
- [ ] Borrar y desactivar cuentas son acciones separadas y protegidas.
- [ ] Las restricciones de historial y de administración se verifican en el servidor.
- [ ] El cierre de ofertas se describe con precisión y conserva postulaciones.
- [ ] Una instalación nueva incluye las rutinas sin pasos manuales omitibles.
- [ ] Una base existente se actualiza sin recrear tablas ni perder datos.
- [ ] El verificador detecta por nombre cualquier procedimiento requerido ausente.
- [ ] El SQL directo pendiente está resuelto o su alcance está documentado con precisión.
- [ ] Las pruebas citadas existen y se pueden reproducir.
- [ ] La compilación y las pruebas pertinentes están registradas, sin presentar pendientes como aprobados.

## 10. Instrucción para retomar con un asistente de código

Se puede copiar esta instrucción al abrir el proyecto en la otra computadora:

> Lee `docs/PLAN_CORRECCIONES_AUDITORIA.md` y revisa el código actual. Implementa las correcciones de auditoría siguiendo sus prioridades y conservando las reglas de permisos, CSRF e historial. Comienza con inspección de solo lectura de la configuración y del esquema real. Trabaja con una copia de la base para pruebas de escritura; no recrees ni modifiques la base real durante la implementación. Prepara migraciones compatibles para la instalación existente y una instalación nueva completa. Ejecuta la compilación y las pruebas reproducibles que correspondan, y entrega un resumen de cambios, evidencias y pendientes. No publiques credenciales ni des por ejecutadas pruebas que no realizaste.

## 11. Hallazgos adicionales de la auditoría independiente

Fecha: 4 de noviembre de 2026.

Después de este plan se realizó una segunda auditoría de solo lectura con dos auditores independientes. Cada uno revisó el código por separado y luego verificó los hallazgos del otro; no hubo hallazgos rechazados. Esta sección agrega lo que no estaba cubierto en las secciones 2 a 8 y reordena todo el trabajo según lo que importa para la evaluación del curso.

### 11.1 Criterio de prioridad para la entrega

El proyecto es un trabajo universitario. El profesor evalúa lo que piden los exámenes y la rúbrica (CRUD con procedimientos almacenados, flujos visibles por rol, instalación reproducible y documentación coherente), no una auditoría de seguridad completa. Por eso se ordena así:

- **P1 – Bloquea o deja mal la demostración:** algo que el profesor puede ver fallar al instalar, iniciar sesión o probar un CRUD.
- **P2 – Visible si el profesor prueba casos de error o lee la documentación:** mensajes falsos, documentación que contradice al código, evidencias que no existen.
- **P3 – Seguridad y robustez:** importante en un sistema real; corregir solo si sobra tiempo o si la rúbrica menciona seguridad.

Si el examen o la rúbrica piden explícitamente seguridad (roles, XSS, CSRF, contraseñas), subir los puntos P3 correspondientes a P2.

### 11.2 Tabla única de prioridades

| Prioridad | Problema | Dónde | Origen |
| --- | --- | --- | --- |
| P1 | Los procedimientos no se instalan con el instalador principal; sin ellos fallan casi todos los paneles | `database/portal_empleo_inclusivo.sql`, migración `20261104` | Sección 5 |
| P1 | Rechazos de negocio de los SP terminan en 503 o mensaje genérico (RR. HH., Soporte, Admin, Ofertas) | Servlets indicados en la sección 2 | Sección 2 |
| P1 | Bucle de redirección infinito para un postulante con `requiere_cambio_clave=1` (tras un restablecimiento desde Soporte no puede entrar) | `SesionFilter.java:62-71`, `PerfilServlet.java:21`, `LoginServlet.java:57` | Nuevo (11.3) |
| P1 | El botón "Evaluar" de RR. HH. se rompe con nombres, títulos o razones sociales que tengan apóstrofo (por ejemplo D'Angelo) | `recursos-humanos.jsp:195` y `:281` | Nuevo (11.3) |
| P1 | El borrado de cuentas existe como SP pero no se puede usar desde la web; la "D" del CRUD de cuentas no se demuestra | `AdminServlet`, `AdminDAO.eliminar` | Sección 3 |
| P2 | Mensaje y confirmación dicen "eliminar oferta y postulaciones", pero solo se cierra | `OfertaServlet.java:40`, `empresa.jsp:35` | Sección 4 |
| P2 | `verificar_instalacion.sql` cuenta procedimientos en lugar de comprobar nombres | `database/verificar_instalacion.sql` | Sección 6 |
| P2 | Evidencia `CRUD_5_OK_ROLLBACK_LIMPIO` sin script; documento de rúbrica desactualizado (fecha, "no se incluye carga de CV", `admin-delete.jsp`) | `docs/VERIFICACION_RUBRICA.md:10-13,72,77,172` | Sección 8 y nuevo |
| P2 | `docs/INSTALACION_WINDOWS.md` dice a la vez "no ejecutar migraciones" y "ejecutar la migración 20261104" | `docs/INSTALACION_WINDOWS.md:22-30` | Nuevo |
| P2 | `OfertaServlet` no valida en el servidor salario, modalidad ni título; editar permite cambiar el estado sin las notificaciones de cierre | `OfertaServlet.java:47-56`, `sp_oferta_actualizar` | Nuevo (11.3) |
| P2 | Tras un error en ofertas el panel de empresa muestra 0 postulaciones (faltan listas en el `forward`) | `OfertaServlet.java:67-72` | Nuevo |
| P2 | `PostulanteServlet` muestra el texto crudo de la excepción SQL | `PostulanteServlet.java:29` | Nuevo |
| P2 | El aviso de éxito de la revisión CONADIS nunca se muestra a RR. HH. | `RevisionConadisServlet.java:68` | Nuevo |
| P2 | Si un postulante se equivoca al cambiar su clave, el mensaje de error se pierde | `PerfilServlet.java:51-53`, `perfil.jsp:20` | Nuevo |
| P2 | Si el admin asigna una clave nueva después de que venció una temporal, el login sigue respondiendo "clave temporal expirada" | `sp_usuario_actualizar_interno`, `UsuarioDAO.java:70` | Nuevo (11.3) |
| P3 | Soporte Técnico puede tomar cualquier cuenta, incluida la del ADMIN | `IncidenciaDAO.java:48-81`, `soporte-tecnico.jsp:19` | Nuevo (11.3) |
| P3 | XSS almacenado en el panel de RR. HH. (mismo origen que el apóstrofo de P1) | `recursos-humanos.jsp:195` | Nuevo (11.3) |
| P3 | El postulante puede borrar evaluaciones de RR. HH. ya publicadas al retirar su postulación | `sp_postulacion_eliminar_usuario`, `PostularServlet.java:24` | Nuevo (11.3) |
| P3 | Login: 3 intentos bloquean cualquier cuenta una hora y el mensaje revela qué correos existen | `UsuarioDAO.java:64-77`, `LoginServlet.java:43` | Nuevo |
| P3 | OTP: reenvío sin límite ni CSRF y nuevos lotes de 5 intentos automáticos | `VerificacionCorreoServlet.java:36,64,92`, `OtpDAO.java:114-120` | Nuevo |
| P3 | `incluyelab_app` se crea con clave `123456` y `GRANT ALL` | `database/portal_empleo_inclusivo.sql:3-4` | Nuevo (11.3) |
| P3 | Registro: si falla un paso posterior al commit se borra la foto CONADIS de una cuenta ya creada | `RegistroServlet.java:83,102` | Nuevo |
| P3 | RR. HH. puede ver cualquier CV creando y borrando un borrador; la foto tiene un control distinto al CV | `CvServlet.java:19`, `FotoPerfilServlet.java:20` | Nuevo |
| P3 | Falta `UNIQUE(id_usuario, id_oferta)` en `postulaciones` | `database/portal_empleo_inclusivo.sql:82-90` | Nuevo |
| P3 | `Passwords.matches` acepta contraseñas guardadas en texto plano; `/logout` por GET; clave demo `123456` del ADMIN | `Passwords.java:56-58`, `LogoutServlet` | Nuevo |
| P3 | Ofertas con fecha futura visibles para el postulante; tickets externos siempre al mismo agente | `OfertaDAO.java:28-29`, `IncidenciaDAO.registrarExterna` | Nuevo |
| P3 | SQL directo restante y código sin uso | Sección 7 | Sección 7 |

### 11.3 Cómo corregir los nuevos puntos importantes

**Bucle de redirección (P1).**

1. En `PerfilServlet.doGet`, no redirigir a `/perfil-profesional` cuando el usuario de la sesión tiene `requiere_cambio_clave=1`; mostrar el formulario de cambio de clave.
2. Revisar en `SesionFilter` el orden de las reglas de cambio de clave y verificación de correo para que una no envíe a la ruta que la otra rechaza.
3. Hacer que `perfil.jsp` envíe `seguridad=1` (o el indicador equivalente) para que los errores se muestren en la misma pantalla.
4. Probar: restablecer la clave de un postulante de prueba desde Soporte, iniciar sesión, cambiar la clave y entrar al panel.

**Apóstrofo y XSS en RR. HH. (P1 por el fallo visible, P3 por la seguridad).**

1. No interpolar datos dentro de `onclick` con comillas simples de JavaScript. Pasar los valores en atributos `data-*` escapados con `h()` y leerlos en JavaScript con `element.dataset`.
2. Aplicar el mismo cambio en `:195` (`iniciarEvaluacion`) y `:281` (`cargarParaEditar`).
3. Probar con un postulante, oferta o empresa cuyo nombre tenga comilla simple, comilla doble y barra invertida.

**Validación de ofertas (P2).** Validar en `OfertaServlet` título obligatorio, modalidad en la lista permitida y salario no negativo, igual que `AdminServlet`. Al recargar tras un error, cargar las mismas listas que `EmpresaServlet`.

**Clave temporal tras cambio del admin (P2).** En `sp_usuario_actualizar_interno`, cuando se cambia la contraseña, poner `requiere_cambio_clave=0` y `clave_temporal_expira=NULL` (o exigir cambio en el primer ingreso de forma explícita). Preparar la migración e incluirla en el instalador.

**Soporte toma cuentas (P3).** Impedir que Soporte verifique o restablezca cuentas internas (`ADMIN`, `SOPORTE_TECNICO`, `RECURSOS_HUMANOS`); exigir que la verificación no sea solo un correo escrito por el propio agente; no mostrar la clave temporal al agente, sino enviarla al correo del titular.

**Evaluaciones publicadas (P3).** Impedir en `sp_postulacion_eliminar_usuario` el retiro si existen evaluaciones publicadas o si la postulación está aceptada, o cambiar el retiro a un estado `retirada` que conserve el historial.

**Clave de `incluyelab_app` (P3).** No fijar `123456` en el instalador; documentar que se defina al instalar y otorgar solo `SELECT, INSERT, UPDATE, DELETE, EXECUTE` sobre el esquema.

### 11.4 Orden recomendado si el tiempo es limitado

1. Instalador con procedimientos y verificador por nombres (sin esto el profesor no puede probar nada).
2. Mensajes de negocio sin 503 y texto correcto de cierre de ofertas.
3. Bucle de redirección y botones de RR. HH. con `data-*`.
4. Borrado de cuentas desde Admin, si la rúbrica exige la "D" física.
5. Documentación coherente: instalación, rúbrica y evidencias reproducibles.
6. Resto de P2.
7. P3 solo si sobra tiempo o la rúbrica lo pide; en ese caso empezar por Soporte → ADMIN y XSS.

Al pedir correcciones a un asistente de código, indicar que siga primero la tabla 11.2 por prioridad y luego los detalles de las secciones 2 a 8.
