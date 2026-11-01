# Accesibilidad de IncluyeLab

El catálogo contiene 13 grupos de necesidades y los vincula con ayudas comprobables del portal: preferencias visuales, navegación por teclado, formularios por pasos, lectura por voz y filtros de apoyos declarados por las empresas.

| N.º | Discapacidad o necesidad | Funcionalidades | ¿Cómo implementarlo? | Estado |
| --- | --- | --- | --- | --- |
| 1 | Visual (ceguera o baja visión) | Audio descriptivo, navegación por flechas, alto contraste y aumento de texto. | JavaScript con `SpeechSynthesis`, CSS para contraste y HTML compatible con lectores de pantalla. | Ayuda visual disponible |
| 2 | Física o motora | Navegación sin mouse, filtros de trabajo remoto y accesibilidad física. | Foco visible, controles táctiles amplios y filtros conectados a ofertas. | Disponible |
| 3 | Auditiva (sordera o hipoacusia) | Ofertas con subtítulos, comunicación escrita o intérprete declarado. | Filtros de apoyos publicados por cada empresa. | Disponible |
| 4 | Intelectual | Formularios sencillos y registro paso a paso. | Etapas visibles, validaciones claras y lectura por voz. | Disponible |
| 5 | Dificultades del habla | Canal de soporte escrito y lectura en voz alta. | Formularios de texto y `SpeechSynthesis`. | Disponible |
| 6 | Autismo con necesidades sensoriales | Bajo estímulo, indicaciones escritas y metodologías visuales. | Filtros JDBC sobre apoyos de las ofertas. | Disponible |
| 7 | Dislexia y dificultades de lectura | Lectura por audio, fuente legible y texto ampliado. | CSS personalizable y controles persistentes. | Disponible |
| 8 | Movilidad manual muy limitada | Navegación por teclado y objetivos táctiles amplios. | Foco visible, enlace de salto y controles de 44 px. | Disponible |
| 9 | Sordoceguera | Navegación textual y compatibilidad semántica. | Etiquetas accesibles y navegación completa por teclado. | Disponible |
| 10 | Psicosocial | Horario flexible, teletrabajo y apoyos de entrevista. | Filtros sobre datos reales de las vacantes. | Disponible |
| 11 | TDAH con necesidades de apoyo | Interfaz estable, tareas por pasos y notificaciones gestionables. | Diseño sin desplazamientos y notificaciones marcables. | Disponible |
| 12 | Condiciones crónicas o fatiga | Filtrar flexibilidad, pausas y trabajo remoto. | Apoyos declarados por la empresa conectados al buscador. | Disponible |
| 13 | Fotosensibilidad | Reducir animaciones y evitar destellos. | CSS con `prefers-reduced-motion`. | Disponible |

## Uso de la ayuda visual

En la barra superior, utiliza los controles de lectura por voz, navegación por flechas, alto contraste y aumento de texto. La voz es síntesis del texto de la página; depende de las voces y del soporte del navegador. No se reproduce automáticamente ni sustituye un lector de pantalla.

Los filtros permiten combinar múltiples apoyos. Describen adaptaciones declaradas por empresas, no diagnósticos ni garantías de compatibilidad individual.

No se borra ni modifica información de usuarios para adaptar este catálogo. La columna histórica `perfiles_postulantes.tipo_discapacidad` no se usa para excluir personas ni se elimina. La verificación CONADIS conserva su flujo de identificación y no solicita un diagnóstico médico.

## Comprobación manual

1. Abre `/accesibilidad`: deben aparecer 13 filas con una ayuda comprobable y estado disponible.
2. Activa alto contraste y texto grande; navega a otra página y comprueba las preferencias.
3. Inicia y detén la lectura por voz; comprueba también el detalle de una oferta. Si no hay voz compatible, debe mostrarse una indicación.
4. Activa navegación por flechas y recorre los controles. Comprueba que puedes escribir y usar las flechas normalmente dentro de campos de texto y selectores; `Tab` sigue disponible.
5. Consulta la tabla desde un teléfono o una ventana estrecha y desplázala con el teclado.

La compatibilidad con lectores de pantalla concretos y dispositivos braille requiere pruebas con esas tecnologías de asistencia; esta entrega no acredita certificación de accesibilidad.

## Referencias técnicas

- [MDN: SpeechSynthesis](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis): síntesis, cancelación y voces disponibles.
- [W3C: interfaces de teclado](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/): conservar las teclas de los controles nativos y el foco visible.

## Tabla MySQL del catálogo

`discapacidades` guarda los 13 registros únicamente con `id_discapacidad`, `codigo` y `nombre`. Las funcionalidades y su estado se conservan en la documentación y la página de accesibilidad, no en esta tabla. Es un catálogo; no asigna diagnósticos a usuarios ni cambia sus perfiles.

La migración `database/migrations/20261027_catalogo_discapacidades.sql` crea la tabla y carga los datos sin borrar información. También se incluye al final de los dos SQL completos. Para actualizar una base existente, ejecuta únicamente la migración, no reimportes el volcado completo.

Consulta en Workbench:

```sql
SELECT * FROM portal_empleo_inclusivo.discapacidades ORDER BY id_discapacidad;
```

La página de accesibilidad conserva su catálogo Java en esta entrega; añadir la tabla no cambia el acceso JDBC de esa página.

Para una tabla creada con las seis columnas anteriores, la migración `20261027_simplificar_discapacidades.sql` elimina solo `funcionalidades`, `implementacion` e `implementada`. Los 13 identificadores, códigos y nombres se conservan.
