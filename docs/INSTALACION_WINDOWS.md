# Instalacion de IncluyeLab en Windows

## Requisitos

- Opción recomendada: Docker Desktop con Compose v2.
- Opción manual: Java 11, Maven/NetBeans, Apache Tomcat 9, MySQL Server 8 y Workbench.

## Opción A: Docker

Desde la raíz del proyecto:

```powershell
Copy-Item .env.example .env
docker compose up --build
```

Portal: `http://localhost:8084/Portal_Empleo_Inclusivo/inicio`.
Mailpit para OTP: `http://localhost:8025`.

MySQL se inicializa solo al crear el volumen vacío. `docker compose down` conserva
la base y los archivos cargados. `docker compose down -v` elimina exclusivamente
los volúmenes de esta instalación Docker.

## Opción B: NetBeans y servicios locales

## 1. Extraer y abrir

1. Extraer el ZIP en una carpeta sin modificar su estructura.
2. En NetBeans seleccionar `File > Open Project`.
3. Elegir la carpeta `Portal_Empleo_Inclusivo`, donde se encuentra `pom.xml`.
4. Configurar Apache Tomcat 9 como servidor del proyecto.

## 2. Crear la base de datos

En una instalacion nueva, abrir MySQL Workbench con una cuenta administradora,
abrir `database/portal_empleo_inclusivo.sql` y ejecutar todo el archivo.

Para una base nueva no ejecutar `portal_empleo_inclusivo_DATOS_ACTUALES.sql` ni
los archivos individuales de `database/migrations`. El instalador principal ya
contiene estructura, datos academicos y cambios vigentes.

Crear después una cuenta MySQL para la aplicación con una contraseña local propia
y concederle permisos únicamente sobre `portal_empleo_inclusivo`. El instalador no
incluye contraseñas de infraestructura.

Si ya existe una base anterior con datos que se deben conservar, no volver a
importar el instalador. Ejecutar `database/actualizar_version_actual.sql` y luego
`database/migrations/20261104_crud_stored_procedures.sql`. Esta migracion solo es
necesaria al actualizar: el instalador principal ya contiene los 25 procedimientos
de los cinco CRUD requeridos por T2.

Finalmente ejecutar `database/verificar_instalacion.sql`. Debe aparecer:

```text
INSTALACION_COMPLETA
```

El verificador vigente comprueba 19 requisitos, incluidos nombres exactos de los
procedimientos, mensajería de postulaciones, tamaño del hash OTP y ausencia del
padrón CONADIS ficticio legado.

La cuenta que ejecuta los scripts debe poder crear tablas, indices, claves
foraneas y triggers. La cuenta `incluyelab_app` es para la aplicacion, no para
administrar la instalacion.

## 3. Configurar la conexion

Crear la carpeta `%USERPROFILE%\IncluyeLab` y copiar allí
`database/db.properties.example` con el nombre `db.properties`. Ajustar usuario,
clave o puerto sin agregar ese archivo privado al ZIP.

Tambien se pueden definir `DB_URL`, `DB_USER` y `DB_PASSWORD` como variables de
entorno del servidor. Las variables tienen prioridad sobre el archivo.

No es obligatorio editar Tomcat. El proyecto no declara `resource-ref` en
`web.xml`, de modo que un Tomcat sin pool JNDI utiliza directamente las variables
o `db.properties`. Si existe un `Resource` real llamado `jdbc/IncluyeLab`, se usa
primero y se mantiene el respaldo externo si el pool falla.

## 4. Compilar y ejecutar

1. En NetBeans seleccionar `Clean and Build`.
2. Confirmar que termine con `BUILD SUCCESS`.
3. Seleccionar `Run` con Tomcat 9.
4. Abrir `http://localhost:8080/Portal_Empleo_Inclusivo/inicio`.

Si Tomcat usa otro puerto, reemplazar `8080` por el puerto configurado.

## 5. Comprobacion rapida

- La portada debe mostrar empresas y ofertas obtenidas desde MySQL.
- El inicio de sesion debe redirigir al panel correspondiente.
- Un rol no debe poder abrir el panel de otro rol modificando la URL.
- Recursos Humanos debe abrir su lista CONADIS sin errores de columnas.
- Soporte Tecnico debe mostrar tickets y auditoria.

Las cuentas academicas estan documentadas en `README.md`. Deben cambiarse antes
de utilizar el sistema fuera de una demostracion local.

## Correo OTP

En Docker no se necesita una cuenta real: Mailpit captura los mensajes. En modo
manual configura `MAIL_HOST`, `MAIL_PORT`, `MAIL_FROM` y `MAIL_AUTH`. Si el servidor
requiere autenticación, añade `MAIL_USER`, `MAIL_PASSWORD` y `MAIL_STARTTLS`.

## Archivos cargados

Los ejemplos de CV y CONADIS viajan dentro de `WEB-INF/demo`. Las cargas nuevas se
guardan fuera del WAR bajo el directorio personal `IncluyeLab`; Docker lo reemplaza
por el volumen persistente `incluyelab_data`.
