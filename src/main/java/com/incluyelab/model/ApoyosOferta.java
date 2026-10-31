package com.incluyelab.model;

import java.util.*;

/** Explicit employer declarations; never inferred from job titles or medical conditions. */
public final class ApoyosOferta {
    private ApoyosOferta() { }
    // code, category, label
    private static final String[][] CATALOGO = {
        {"rampas","movilidad","Rampas"},
        {"ascensores","movilidad","Ascensores"},
        {"escritorios","movilidad","Escritorios regulables"},
        {"perifericos","movilidad","Perifericos adaptados"},
        {"lector","visual","Compatibilidad con lectores de pantalla (NVDA/JAWS)"},
        {"macrotipos","visual","Macrotipos"},
        {"contraste","visual","Alto contraste en herramientas de trabajo"},
        {"braille","visual","Teclados Braille"},
        {"escrita","auditiva","Comunicacion escrita"},
        {"subtitulos","auditiva","Subtitulos en reuniones"},
        {"lsp","auditiva","Interprete de lengua de senas peruana (LSP)"},
        {"flexible","flexible","Horario flexible"},
        {"pausas","pausas","Pausas activas"}
    };
    public static String[][] catalogo() {
        return Arrays.stream(CATALOGO).map(String[]::clone).toArray(String[][]::new);
    }
    public static String validar(String[] seleccion) {
        Set<String> valores = new LinkedHashSet<>();
        if (seleccion != null) for (String valor : seleccion) {
            if (Arrays.stream(CATALOGO).noneMatch(a -> a[0].equals(valor)))
                throw new IllegalArgumentException("Selecciona adaptaciones validas.");
            valores.add(valor);
        }
        return String.join(",",valores);
    }
    public static Set<String> codigos(String seleccion) {
        return seleccion == null || seleccion.isEmpty() ? Collections.emptySet()
                : new LinkedHashSet<>(Arrays.asList(seleccion.split(",")));
    }
    public static String categorias(String seleccion) {
        Set<String> valores = codigos(seleccion), categorias = new LinkedHashSet<>();
        for (String[] a : CATALOGO) if (valores.contains(a[0])) categorias.add(a[1]);
        return String.join(",",categorias);
    }
    public static String etiquetas(String seleccion) {
        Set<String> valores = codigos(seleccion);
        List<String> etiquetas = new ArrayList<>();
        for (String[] a : CATALOGO) if (valores.contains(a[0])) etiquetas.add(a[2]);
        return String.join("; ",etiquetas);
    }
}
