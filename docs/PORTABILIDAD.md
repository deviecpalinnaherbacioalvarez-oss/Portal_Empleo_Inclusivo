# Portabilidad de IncluyeLab

## Conexión efectiva

`Conexion.java` intenta, en orden: `java:comp/env/jdbc/IncluyeLab`, variables o
propiedades JVM `DB_URL`, `DB_USER`, `DB_PASSWORD`, y el archivo indicado por
`INCLUYELAB_DB_CONFIG` o `~/IncluyeLab/db.properties`. La laptop auditada usa el
archivo externo. No se copiaron ni documentaron sus credenciales.

## Comparación de base

La base original auditada de la laptop contiene 18 tablas, 25 procedimientos, 3
triggers y ninguna función. La instalación limpia actual contiene 18 tablas, los
mismos 25 procedimientos, los mismos 3 triggers y ninguna función. La base original
conservaba `padron_conadis`, resto ficticio eliminado del modelo actual; la limpia
incorpora en su lugar `mensajes_postulacion` para la conversación privada.
También se detectaron restricciones antiguas en OTP y CONADIS; la actualización
consolidada contiene la normalización, pero no fue ejecutada sobre la base original.

Los registros operativos adicionales de la laptop no se exportaron. El instalador
contiene solo datos académicos: 14 cuentas, 9 empresas, 11 ofertas, 2 postulaciones,
2 verificaciones CONADIS, 1 evaluación de RR. HH. y 1 incidencia interna de Soporte.

## Archivos externos

Los ejemplos necesarios están en `src/main/webapp/WEB-INF/demo`. Las cargas reales
permanecen fuera del WAR. Compose monta `incluyelab_data` en la ubicación usada por
CV, fotos y carnets privados. No se incorporó ningún archivo del perfil local.

## Docker

`Dockerfile` compila con Java 11/Maven y ejecuta sobre Tomcat 9. `compose.yaml`
incluye MySQL 8, espera de disponibilidad, volúmenes persistentes y Mailpit. MySQL
ejecuta el instalador únicamente cuando crea un volumen vacío.

## Pruebas realizadas

- Maven genera correctamente el WAR.
- Instalación desde cero en una instancia MySQL 8.0.46 separada, con otro puerto y
  directorio de datos: `INSTALACION_COMPLETA` con 19 de 19 controles.
- Copia limpia: 18 tablas, 25 procedimientos, 3 triggers y 0 funciones.
- Datos académicos: los conteos indicados arriba.
- Los recursos demo de CV y CONADIS están dentro del WAR.
- Portada y pantalla de ingreso: respuesta HTTP 200 contra la copia aislada.
- Inicio de sesión y apertura del panel de los cinco roles: Administrador Central,
  Empresa, Postulante, Recursos Humanos y Soporte Técnico.
- Procedimientos de los cinco CRUD: `CRUD_5_OK_ROLLBACK_LIMPIO`; la prueba creó
  datos temporales dentro de una transacción y los retiró mediante `ROLLBACK`.
- Actualización consolidada y migración de procedimientos sobre la copia aislada:
  el verificador permaneció completo.
- Mensajería: envío postulante-empresa y respuesta empresa-postulante comprobados;
  ambos mensajes se conservaron en el hilo y generaron notificación.
- Autorización horizontal: una segunda empresa recibió HTTP 404 al intentar abrir
  una conversación que no pertenecía a sus ofertas.

## Pruebas pendientes

- `docker compose up --build`: Docker no está instalado en la laptop auditada.
- Recepción OTP por Mailpit y recorrido integral sobre contenedores: pendientes por
  la misma razón.
- Validación de `compose.yaml` mediante `docker compose config`: pendiente por la
  misma ausencia de Docker; el archivo se revisó estáticamente.
- La instalación local existente no se presenta como sustituto de esa evidencia.
