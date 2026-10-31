package com.incluyelab.security;

import java.text.Normalizer;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Locale;

/**
 * Reglas de formato del carnet CONADIS. RRHH completa los datos de identificación
 * y selecciona una categoría del catálogo; no se guarda un diagnóstico CIE-10.
 */
public final class ConadisValidator {
    private static final String NOMBRE = "[\\p{L}][\\p{L}' .-]{0,78}[\\p{L}.]";

    private ConadisValidator() { }

    /** Acepta "RD406923", "RD:406923", "rd 406923" o "406923" y devuelve solo los digitos. */
    public static String rui(String valor) {
        String v = valor == null ? "" : valor.toUpperCase(Locale.ROOT).replaceAll("[\\s:\\-]", "");
        if (v.startsWith("RD")) v = v.substring(2);
        if (!v.matches("[0-9]{4,8}")) throw new IllegalArgumentException("Ingresa el RUI tal como aparece en tu carnet (por ejemplo, RD406923).");
        return v;
    }

    public static String dni(String valor) {
        String v = valor == null ? "" : valor.trim();
        if (!v.matches("[0-9]{8}")) throw new IllegalArgumentException("El DNI debe tener exactamente 8 digitos.");
        return v;
    }

    /** Normaliza para guardar: mayusculas y espacios simples, conservando tildes. */
    public static String nombre(String valor, String campo) {
        String v = valor == null ? "" : valor.trim().replaceAll("\\s+", " ").toUpperCase(Locale.forLanguageTag("es-PE"));
        if (!v.matches(NOMBRE)) throw new IllegalArgumentException(campo + ": escribe entre 2 y 80 letras, tal como figura en el carnet.");
        return v;
    }

    public static LocalDate caducidad(String valor) {
        LocalDate fecha;
        try { fecha = LocalDate.parse(valor == null ? "" : valor.trim()); }
        catch (DateTimeParseException ex) { throw new IllegalArgumentException("Ingresa la fecha de caducidad del carnet."); }
        if (fecha.isBefore(LocalDate.now()))
            throw new IllegalArgumentException("Tu carnet CONADIS esta vencido. Renuevalo y sube el carnet vigente para continuar.");
        if (fecha.isAfter(LocalDate.now().plusYears(20))) throw new IllegalArgumentException("Revisa la fecha de caducidad: no es valida.");
        return fecha;
    }

    /** Comparacion tolerante a tildes, mayusculas y espacios. */
    public static boolean mismoNombre(String a, String b) { return clave(a).equals(clave(b)); }

    private static String clave(String s) {
        return Normalizer.normalize(s == null ? "" : s, Normalizer.Form.NFD).replaceAll("\\p{M}", "")
                .toUpperCase(Locale.ROOT).replaceAll("[^A-Z ]", " ").trim().replaceAll("\\s+", " ");
    }
}
