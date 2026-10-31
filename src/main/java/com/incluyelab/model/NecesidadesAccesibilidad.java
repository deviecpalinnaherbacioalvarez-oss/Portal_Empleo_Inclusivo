package com.incluyelab.model;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/** Alcance del portal: necesidades de accesibilidad, no diagnósticos médicos. */
public final class NecesidadesAccesibilidad {
    private NecesidadesAccesibilidad() { }

    private static final List<Necesidad> CATALOGO = Collections.unmodifiableList(Arrays.asList(
        new Necesidad("visual", "Visual (ceguera o baja visión)",
            "Audio descriptivo, navegación por flechas, alto contraste y aumento de texto.",
            "JavaScript con SpeechSynthesis, CSS para contraste y HTML compatible con lectores de pantalla.", true),
        new Necesidad("fisica_motora", "Física o motora",
            "Navegación sin mouse, filtros de trabajo remoto y accesibilidad física.",
            "Eventos de teclado en JavaScript y filtros relacionados con los datos de las empresas.", false),
        new Necesidad("auditiva", "Auditiva (sordera o hipoacusia)",
            "Subtítulos, entrevistas por chat y videos en Lengua de Señas Peruana (LSP).",
            "Chat con backend, videos subtitulados y contenido grabado con intérpretes de LSP.", false),
        new Necesidad("intelectual", "Intelectual",
            "Formularios sencillos, instrucciones habladas, imágenes y postulación paso a paso.",
            "HTML y JavaScript con formularios divididos en etapas, pictogramas y lectura por voz.", false),
        new Necesidad("habla", "Dificultades del habla (afasia, disartria, etc.)",
            "Entrevistas escritas, respuestas predeterminadas y comunicación mediante texto a voz.",
            "Chat y botones de comunicación aumentativa y alternativa (CAA), usando SpeechSynthesis.", false),
        new Necesidad("autismo_sensorial", "Autismo con necesidades sensoriales",
            "Filtros de ruido, iluminación, interacción social y organización del ambiente laboral.",
            "Campos adicionales en la base de datos y filtros dinámicos en JavaScript.", false),
        new Necesidad("dislexia", "Dislexia y dificultades de lectura",
            "Lectura por audio, texto simplificado, ajuste de fuente y espaciado.",
            "CSS personalizable, JavaScript y explicaciones redactadas en lenguaje sencillo.", false),
        new Necesidad("movilidad_manual", "Movilidad manual muy limitada",
            "Comandos de voz y navegación mediante una sola tecla o pulsador.",
            "API SpeechRecognition donde sea compatible, además de navegación accesible para dispositivos de asistencia.", false),
        new Necesidad("sordoceguera", "Sordoceguera",
            "Navegación textual accesible, soporte para lectores de pantalla y líneas braille.",
            "HTML semántico, etiquetas accesibles, navegación completa por teclado y pruebas con tecnologías de asistencia.", false),
        new Necesidad("psicosocial", "Psicosocial",
            "Filtros de horarios flexibles, teletrabajo y posibilidad de solicitar ajustes durante entrevistas.",
            "Nuevos campos del perfil laboral y filtros de condiciones de trabajo en la base de datos.", false),
        new Necesidad("tdah", "TDAH con necesidades de apoyo",
            "Modo sin distracciones, tareas divididas en pasos y recordatorios de postulación.",
            "CSS para interfaz simplificada, JavaScript para seguimiento de pasos y notificaciones opcionales.", false),
        new Necesidad("cronicas_fatiga", "Discapacidades asociadas a condiciones crónicas o fatiga",
            "Filtrar trabajos flexibles, descansos disponibles y opciones remotas.",
            "Registrar características de jornada y adaptaciones ofrecidas por cada empresa; conectarlas con el buscador.", false),
        new Necesidad("fotosensibilidad", "Fotosensibilidad o sensibilidad a estímulos visuales",
            "Desactivar animaciones, evitar destellos y ofrecer un modo visual tranquilo.",
            "CSS con prefers-reduced-motion y controles de accesibilidad personalizables.", false)
    ));

    public static List<Necesidad> catalogo() { return CATALOGO; }

    /** Entrada inmutable para mantener el mismo catálogo en el Servlet y la vista. */
    public static final class Necesidad {
        private final String codigo;
        private final String nombre;
        private final String funciones;
        private final String implementacion;
        private final boolean disponible;

        private Necesidad(String codigo, String nombre, String funciones,
                String implementacion, boolean disponible) {
            this.codigo = codigo;
            this.nombre = nombre;
            this.funciones = funciones;
            this.implementacion = implementacion;
            this.disponible = disponible;
        }

        public String getCodigo() { return codigo; }
        public String getNombre() { return nombre; }
        public String getFunciones() { return funciones; }
        public String getImplementacion() { return implementacion; }
        public boolean isDisponible() { return disponible; }
        public String getEstado() { return disponible ? "Disponible: ayuda visual" : "Planificado"; }
    }
}
