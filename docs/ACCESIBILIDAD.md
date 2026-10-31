# Accesibilidad de IncluyeLab

El catálogo de alcance contiene únicamente estas 13 necesidades. En esta entrega se implementa la ayuda visual de la fila 1; las funciones de las filas 2 a 13 quedan planificadas. La página pública `/accesibilidad` muestra el catálogo y su estado.

| N.º | Discapacidad o necesidad | Funcionalidades | ¿Cómo implementarlo? | Estado |
| --- | --- | --- | --- | --- |
| 1 | Visual (ceguera o baja visión) | Audio descriptivo, navegación por flechas, alto contraste y aumento de texto. | JavaScript con `SpeechSynthesis`, CSS para contraste y HTML compatible con lectores de pantalla. | Ayuda visual disponible |
| 2 | Física o motora | Navegación sin mouse, filtros de trabajo remoto y accesibilidad física. | Eventos de teclado en JavaScript y filtros relacionados con los datos de las empresas. | Planificado |
| 3 | Auditiva (sordera o hipoacusia) | Subtítulos, entrevistas por chat y videos en Lengua de Señas Peruana (LSP). | Chat con backend, videos subtitulados y contenido grabado con intérpretes de LSP. | Planificado |
| 4 | Intelectual | Formularios sencillos, instrucciones habladas, imágenes y postulación paso a paso. | HTML y JavaScript con formularios divididos en etapas, pictogramas y lectura por voz. | Planificado |
| 5 | Dificultades del habla (afasia, disartria, etc.) | Entrevistas escritas, respuestas predeterminadas y comunicación mediante texto a voz. | Chat y botones de comunicación aumentativa y alternativa (CAA), usando `SpeechSynthesis`. | Planificado |
| 6 | Autismo con necesidades sensoriales | Filtros de ruido, iluminación, interacción social y organización del ambiente laboral. | Campos adicionales en la base de datos y filtros dinámicos en JavaScript. | Planificado |
| 7 | Dislexia y dificultades de lectura | Lectura por audio, texto simplificado, ajuste de fuente y espaciado. | CSS personalizable, JavaScript y explicaciones redactadas en lenguaje sencillo. | Planificado |
| 8 | Movilidad manual muy limitada | Comandos de voz y navegación mediante una sola tecla o pulsador. | API `SpeechRecognition` donde sea compatible, además de navegación accesible para dispositivos de asistencia. | Planificado |
| 9 | Sordoceguera | Navegación textual accesible, soporte para lectores de pantalla y líneas braille. | HTML semántico, etiquetas accesibles, navegación completa por teclado y pruebas con tecnologías de asistencia. | Planificado |
| 10 | Psicosocial | Filtros de horarios flexibles, teletrabajo y posibilidad de solicitar ajustes durante entrevistas. | Nuevos campos del perfil laboral y filtros de condiciones de trabajo en la base de datos. | Planificado |
| 11 | TDAH con necesidades de apoyo | Modo sin distracciones, tareas divididas en pasos y recordatorios de postulación. | CSS para interfaz simplificada, JavaScript para seguimiento de pasos y notificaciones opcionales. | Planificado |
| 12 | Discapacidades asociadas a condiciones crónicas o fatiga | Filtrar trabajos flexibles, descansos disponibles y opciones remotas. | Registrar características de jornada y adaptaciones ofrecidas por cada empresa; conectarlas con el buscador. | Planificado |
| 13 | Fotosensibilidad o sensibilidad a estímulos visuales | Desactivar animaciones, evitar destellos y ofrecer un modo visual tranquilo. | CSS con `prefers-reduced-motion` y controles de accesibilidad personalizables. | Planificado |

## Uso de la ayuda visual

En la barra superior, utiliza los controles de lectura por voz, navegación por flechas, alto contraste y aumento de texto. La voz es síntesis del texto de la página; depende de las voces y del soporte del navegador. No se reproduce automáticamente ni sustituye un lector de pantalla.

La selección de múltiples necesidades y la personalización de filtros de empleo ampliados quedan previstas para una siguiente etapa. Los filtros de apoyos ya existentes se conservan: describen adaptaciones declaradas por empresas, no diagnósticos ni garantías de compatibilidad individual.

No se borra ni modifica información de usuarios para adaptar este catálogo. La columna histórica `perfiles_postulantes.tipo_discapacidad` no se usa para excluir personas ni se elimina. La verificación CONADIS conserva su flujo de identificación y no solicita un diagnóstico médico.

## Comprobación manual

1. Abre `/accesibilidad`: deben aparecer 13 filas y solo la ayuda visual como disponible.
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
