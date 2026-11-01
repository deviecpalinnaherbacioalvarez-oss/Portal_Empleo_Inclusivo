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
            "Controles utilizables con teclado, foco visible y filtros de rampas, ascensores y modalidad remota.", true),
        new Necesidad("auditiva", "Auditiva (sordera o hipoacusia)",
            "Búsqueda de ofertas con subtítulos, comunicación escrita e intérprete de LSP declarado.",
            "Filtros conectados con los apoyos publicados por cada empresa.", true),
        new Necesidad("intelectual", "Intelectual",
            "Formularios sencillos, registro por pasos e instrucciones directas.",
            "Registro dividido en etapas, mensajes de validación y lectura por voz opcional.", true),
        new Necesidad("habla", "Dificultades del habla (afasia, disartria, etc.)",
            "Canales escritos y lectura en voz alta del contenido del portal.",
            "Formulario de soporte escrito y herramienta SpeechSynthesis del navegador.", true),
        new Necesidad("autismo_sensorial", "Autismo con necesidades sensoriales",
            "Filtros de bajo estímulo, indicaciones escritas y metodologías visuales.",
            "Categorías de apoyo consultadas directamente desde las ofertas en MySQL.", true),
        new Necesidad("dislexia", "Dislexia y dificultades de lectura",
            "Lectura por audio, texto simplificado, ajuste de fuente y espaciado.",
            "Fuente legible, texto ampliado, espaciado estable y lectura por voz.", true),
        new Necesidad("movilidad_manual", "Movilidad manual muy limitada",
            "Navegación completa con teclado, objetivos táctiles amplios y enlace para saltar al contenido.",
            "HTML semántico, foco visible y controles de al menos 44 por 44 píxeles.", true),
        new Necesidad("sordoceguera", "Sordoceguera",
            "Navegación textual accesible, soporte para lectores de pantalla y líneas braille.",
            "HTML semántico, etiquetas accesibles y navegación completa por teclado.", true),
        new Necesidad("psicosocial", "Psicosocial",
            "Filtros de horarios flexibles, teletrabajo y posibilidad de solicitar ajustes durante entrevistas.",
            "Filtros de modalidad remota, horario flexible y apoyos declarados por la empresa.", true),
        new Necesidad("tdah", "TDAH con necesidades de apoyo",
            "Modo sin distracciones, tareas divididas en pasos y recordatorios de postulación.",
            "Interfaz estable, formularios por pasos y notificaciones que pueden marcarse como leídas.", true),
        new Necesidad("cronicas_fatiga", "Discapacidades asociadas a condiciones crónicas o fatiga",
            "Filtrar trabajos flexibles, descansos disponibles y opciones remotas.",
            "Filtros de trabajo remoto, flexibilidad y pausas ofrecidas en cada vacante.", true),
        new Necesidad("fotosensibilidad", "Fotosensibilidad o sensibilidad a estímulos visuales",
            "Desactivar animaciones, evitar destellos y ofrecer un modo visual tranquilo.",
            "Respeto de prefers-reduced-motion y controles de accesibilidad personalizables.", true)
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
        public String getEstado() { return disponible ? "Disponible" : "En evaluación"; }
    }
}
